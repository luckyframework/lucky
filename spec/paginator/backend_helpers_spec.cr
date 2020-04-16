require "../spec_helper"

class FakeUser < Avram::Model
  table do
  end

  def self.database
    UnusedDatabase
  end

  class BaseQuery
    # Override so it doesn't hit the db and we get 2 pages of results
    def select_count
      50
    end
  end
end

class Paginatable
  include Lucky::Paginator::BackendHelpers
  include ContextHelper

  def initialize(@page : String? = nil)
  end

  def call
    paginate(FakeUser::BaseQuery.new)
  end

  def call_array
    paginate_array([1]*50)
  end

  def params
    Params.new(@page)
  end

  def context
    build_context
  end

  class Params
    getter page

    def initialize(@page : String?)
    end

    def get?(_value) : String?
      @page
    end
  end
end

class PaginatableWithOverriddenMethods < Paginatable
  def paginator_page : Int32
    2
  end

  def paginator_per_page : Int32
    10
  end
end

describe Lucky::Paginator::BackendHelpers do
  it "uses default of page 1 and per_page of 25" do
    pages, records = Paginatable.new.call

    pages.page.should eq(1)
    pages.per_page.should eq(25)
    pages.total.should eq(2)
    records.query.offset.should eq(0)
    records.query.limit.should eq(25)
  end

  it "uses the 'page' param if given" do
    pages, records = Paginatable.new(page: "2").call

    pages.page.should eq(2)
    pages.per_page.should eq(25)
    pages.total.should eq(2)
    records.query.offset.should eq(25)
    records.query.limit.should eq(25)
  end

  it "accept array with default" do
    pages, records = Paginatable.new.call_array

    pages.page.should eq(1)
    pages.per_page.should eq(25)
    pages.total.should eq(2)
    records.size.should eq(25)
  end

  it "uses array with the 'page' param if given" do
    pages, records = Paginatable.new(page: "2").call_array

    pages.page.should eq(2)
    pages.per_page.should eq(25)
    pages.total.should eq(2)
    records.size.should eq(25)
  end

  it "return empty array if page is overflowed" do
    pages, records = Paginatable.new(page: "3").call_array

    pages.page.should eq(3)
    pages.per_page.should eq(25)
    pages.total.should eq(2)
    records.size.should eq(0)
  end

  it "allows overriding 'paginator_page' and 'paginator_per_page'" do
    pages, records = PaginatableWithOverriddenMethods.new.call

    pages.page.should eq(2)
    pages.per_page.should eq(10)
    pages.total.should eq(5)
    records.query.offset.should eq(10)
    records.query.limit.should eq(10)
  end
end
