require 'active_support/test_case'
require 'active_support/testing/stream'

module ValidationsRepairHelper
  extend ActiveSupport::Concern

  module ClassMethods
    def repair_validations(*model_classes)
      teardown do
        model_classes.each(&:clear_validators!)
      end
    end
  end

  def repair_validations(*model_classes)
    yield if block_given?
  ensure
    model_classes.each(&:clear_validators!)
  end
end

class ActiveSupport::TestCase
  # include ActiveRecord::TestFixtures
  include ActiveRecord::ValidationsRepairHelper
  include ActiveSupport::Testing::MethodCallAssertions

  # self.fixture_path = FIXTURES_ROOT
  # self.use_instantiated_fixtures  = false
  # self.use_transactional_tests = true

  # def create_fixtures(*fixture_set_names, &block)
  #   ActiveRecord::FixtureSet.create_fixtures(ActiveSupport::TestCase.fixture_path, fixture_set_names, fixture_class_names, &block)
  # end
end

class SQLCounter
  class << self
    attr_accessor :ignored_sql, :log, :log_all
    def clear_log; self.log = []; self.log_all = []; end
  end

  self.clear_log

  self.ignored_sql = [
    /^PRAGMA/,
    /^SELECT currval/,
    /^SELECT CAST/,
    /^SELECT @@IDENTITY/,
    /^SELECT @@ROWCOUNT/,
    /^SAVEPOINT/,
    /^ROLLBACK TO SAVEPOINT/,
    /^RELEASE SAVEPOINT/,
    /^SHOW max_identifier_length/,
    /^BEGIN/,
    /^COMMIT/,/^SHOW FULL TABLES/i,
    /^SHOW FULL FIELDS/,
    /^SHOW CREATE TABLE /i,
    /^SHOW VARIABLES /,
    /^\s*SELECT (?:column_name|table_name)\b.*\bFROM information_schema\.(?:key_column_usage|tables)\b/im
  ]

  attr_reader :ignore

  def initialize(ignore = Regexp.union(self.class.ignored_sql))
    @ignore = ignore
  end

  def call(name, start, finish, message_id, values)
    sql = values[:sql]

    # FIXME: this seems bad. we should probably have a better way to indicate
    # the query was cached
    return if 'CACHE' == values[:name]

    self.class.log_all << sql
    self.class.log << sql unless ignore =~ sql
  end
end

class TestCase < ActiveSupport::TestCase #:nodoc:
  include ActiveSupport::Testing::Stream

  def teardown
    SQLCounter.clear_log
  end

  def assert_date_from_db(expected, actual, message = nil)
    assert_equal expected.to_s, actual.to_s, message
  end

  def capture_sql
    SQLCounter.clear_log
    yield
    SQLCounter.log_all.dup
  end

  def assert_sql(*patterns_to_match)
    capture_sql { yield }
  ensure
    failed_patterns = []
    patterns_to_match.each do |pattern|
      failed_patterns << pattern unless SQLCounter.log_all.any?{ |sql| pattern === sql }
    end
    assert failed_patterns.empty?, "Query pattern(s) #{failed_patterns.map(&:inspect).join(', ')} not found.#{SQLCounter.log.size == 0 ? '' : "\nQueries:\n#{SQLCounter.log.join("\n")}"}"
  end

  def assert_queries(num = 1, options = {})
    ignore_none = options.fetch(:ignore_none) { num == :any }
    SQLCounter.clear_log
    x = yield
    the_log = ignore_none ? SQLCounter.log_all : SQLCounter.log
    if num == :any
      assert_operator the_log.size, :>=, 1, "1 or more queries expected, but none were executed."
    else
      mesg = "#{the_log.size} instead of #{num} queries were executed.#{the_log.size == 0 ? '' : "\nQueries:\n#{the_log.join("\n")}"}"
      assert_equal num, the_log.size, mesg
    end
    x
  end

  def assert_no_queries(options = {}, &block)
    options.reverse_merge! ignore_none: true
    assert_queries(0, options, &block)
  end

  def assert_column(model, column_name, msg=nil)
    assert has_column?(model, column_name), msg
  end

  def assert_no_column(model, column_name, msg=nil)
    assert_not has_column?(model, column_name), msg
  end

  def has_column?(model, column_name)
    model.reset_column_information
    model.column_names.include?(column_name.to_s)
  end
end

class MysqlTestCase < TestCase
  def self.run(*args)
    super if current_adapter?(:MysqlAdapter)
  end
end

class MyTestCase < ActiveSupport::TestCase
# TODO
end


