require "../../spec_helper"

private def build_pages(page = 1, per_page = 1, item_count = 1, full_path = "/items") : Lucky::Paginator
  Lucky::Paginator.new(
    page: page,
    per_page: per_page,
    item_count: item_count,
    full_path: full_path)
end

describe Lucky::Paginator do
  describe "#page" do
    it "returns the current page" do
      build_pages(page: 2).page.should eq(2)
    end

    it "makes sure the page is not 0 or less" do
      build_pages(page: 0).page.should eq(1)
      build_pages(page: -1).page.should eq(1)
    end
  end

  describe "#one_page?" do
    it "returns true if there is just one page" do
      build_pages(per_page: 1, item_count: 1).one_page?.should be_true
    end

    it "returns false if there is more than one page" do
      build_pages(per_page: 1, item_count: 2).one_page?.should be_false
    end
  end

  describe "#offset" do
    it "returns the number of records to skip" do
      build_pages(page: 2, per_page: 10, item_count: 20).offset.should eq(10)
      build_pages(page: 1, per_page: 10, item_count: 20).offset.should eq(0)
    end
  end

  describe "#total" do
    it "returns a rounded total pages" do
      build_pages(per_page: 10, item_count: 0).total.should eq(0)
      build_pages(per_page: 10, item_count: 1).total.should eq(1)
      build_pages(per_page: 10, item_count: 15).total.should eq(2)
    end
  end

  describe "#last_page?" do
    it "returns true if the current page is the last one" do
      build_pages(page: 2, per_page: 1, item_count: 2).last_page?.should eq(true)
      build_pages(page: 1, per_page: 1, item_count: 1).last_page?.should eq(true)
    end

    it "returns false if the current page is not the last one" do
      build_pages(page: 1, per_page: 1, item_count: 2).last_page?.should eq(false)
    end
  end

  describe "#first_page?" do
    it "returns true if the current page is the first one" do
      build_pages(page: 1, per_page: 1, item_count: 1).first_page?.should eq(true)
    end

    it "otherwise returns false" do
      build_pages(page: 2, per_page: 1, item_count: 2).first_page?.should eq(false)
    end
  end

  describe "#overflowed?" do
    it "returns true if the current page is past the last page" do
      build_pages(page: 2, per_page: 1, item_count: 1).overflowed?.should eq(true)
    end

    it "otherwise returns false" do
      build_pages(page: 1, per_page: 1, item_count: 1).overflowed?.should eq(false)
    end
  end

  describe "#item_range" do
    it "return the range of items on the current page" do
      item_range = build_pages(page: 1, per_page: 5, item_count: 20).item_range
      item_range.begin.should eq(1)
      item_range.end.should eq(5)

      item_range = build_pages(page: 2, per_page: 5, item_count: 12).item_range
      item_range.begin.should eq(6)
      item_range.end.should eq(10)

      item_range = build_pages(page: 3, per_page: 5, item_count: 12).item_range
      item_range.begin.should eq(11)
      item_range.end.should eq(12)
    end
  end

  describe "#previous_page" do
    it "returns the next page" do
      build_pages(page: 0, per_page: 3, item_count: 10).previous_page.should be_nil
      build_pages(page: 1, per_page: 3, item_count: 10).previous_page.should be_nil
      build_pages(page: 3, per_page: 3, item_count: 10).previous_page.should eq(2)
      build_pages(page: 4, per_page: 3, item_count: 10).previous_page.should eq(3)
    end
  end

  describe "#next_page" do
    it "returns the next page" do
      build_pages(page: 1, per_page: 3, item_count: 10).next_page.should eq(2)
      build_pages(page: 3, per_page: 3, item_count: 10).next_page.should eq(4)
      build_pages(page: 4, per_page: 3, item_count: 10).next_page.should be_nil
      build_pages(page: 9, per_page: 3, item_count: 10).next_page.should be_nil
    end
  end

  describe "#path_to_page" do
    it "adds a query param to the path" do
      path = build_pages(full_path: "/comments").path_to_page(1)

      path.should eq("/comments?page=1")
    end

    it "appends to query param if some are already set" do
      path = build_pages(full_path: "/comments?filter=published").path_to_page(1)

      path.should eq("/comments?filter=published&page=1")
    end

    it "overwrites page query param" do
      path = build_pages(full_path: "/comments?page=1").path_to_page(2)

      path.should eq("/comments?page=2")
    end
  end

  describe "#path_to_next" do
    it "returns the path to the next page if there is a next page" do
      path = build_pages(page: 1, per_page: 1, item_count: 2).path_to_next

      path.to_s.should end_with("?page=2")
    end

    it "returns nil if there is not next page" do
      path = build_pages(page: 1, per_page: 1, item_count: 1).path_to_next

      path.should be_nil
    end
  end

  describe "#path_to_previous" do
    it "returns the path to the previous page if there is a previous page" do
      path = build_pages(page: 2, per_page: 1, item_count: 2).path_to_previous

      path.to_s.should end_with("?page=1")
    end

    it "returns nil if there is not previous page" do
      path = build_pages(page: 1, per_page: 1, item_count: 1).path_to_previous

      path.should be_nil
    end
  end

  describe "#series" do
    it "allows customizing the series" do
      pages = build_pages(page: 20, per_page: 1, item_count: 40)

      series = pages.series(begin: 2, left_of_current: 2, right_of_current: 2, end: 2)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 1),
        Lucky::Paginator::Page.new(pages, 2),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 18),
        Lucky::Paginator::Page.new(pages, 19),
        Lucky::Paginator::CurrentPage.new(pages, 20),
        Lucky::Paginator::Page.new(pages, 21),
        Lucky::Paginator::Page.new(pages, 22),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 39),
        Lucky::Paginator::Page.new(pages, 40),
      ])
    end

    it "doesn't add gaps when begining/ending are next to current pages" do
      pages = build_pages(page: 4, per_page: 1, item_count: 7)

      series = pages.series(begin: 1, left_of_current: 2, right_of_current: 2, end: 1)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 1),
        Lucky::Paginator::Page.new(pages, 2),
        Lucky::Paginator::Page.new(pages, 3),
        Lucky::Paginator::CurrentPage.new(pages, 4),
        Lucky::Paginator::Page.new(pages, 5),
        Lucky::Paginator::Page.new(pages, 6),
        Lucky::Paginator::Page.new(pages, 7),
      ])
    end

    it "adds gaps when there is just 1 page in between middle and edges" do
      pages = build_pages(page: 4, per_page: 1, item_count: 7)

      series = pages.series(begin: 1, left_of_current: 1, right_of_current: 1, end: 1)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 1),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 3),
        Lucky::Paginator::CurrentPage.new(pages, 4),
        Lucky::Paginator::Page.new(pages, 5),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 7),
      ])
    end

    it "when 'begin' or 'end' is 0 it leaves of the pages and gap" do
      pages = build_pages(page: 20, per_page: 1, item_count: 40)

      series = pages.series(begin: 0, left_of_current: 1, right_of_current: 1, end: 0)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 19),
        Lucky::Paginator::CurrentPage.new(pages, 20),
        Lucky::Paginator::Page.new(pages, 21),
      ])
    end

    it "when 'left/right_of_current' are 0 it keeps the gap between begin/end" do
      pages = build_pages(page: 20, per_page: 1, item_count: 40)

      series = pages.series(begin: 1, left_of_current: 0, right_of_current: 0, end: 1)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 1),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::CurrentPage.new(pages, 20),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 40),
      ])
    end

    it "when all options are 0 it generates just a current page" do
      pages = build_pages(page: 20, per_page: 1, item_count: 40)

      series = pages.series(begin: 0, left_of_current: 0, right_of_current: 0, end: 0)

      series.should eq([
        Lucky::Paginator::CurrentPage.new(pages, 20),
      ])
    end

    it "returns the correct series when at the last page" do
      pages = build_pages(page: 40, per_page: 1, item_count: 40)

      series = pages.series(begin: 0, left_of_current: 1, right_of_current: 1, end: 1)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 39),
        Lucky::Paginator::CurrentPage.new(pages, 40),
      ])
    end

    it "returns the correct series when near the last page" do
      pages = build_pages(page: 39, per_page: 1, item_count: 40)

      series = pages.series(begin: 0, left_of_current: 1, right_of_current: 2, end: 1)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 38),
        Lucky::Paginator::CurrentPage.new(pages, 39),
        Lucky::Paginator::CurrentPage.new(pages, 40),
      ])
    end

    it "returns the correct series when at the first page" do
      pages = build_pages(page: 1, per_page: 1, item_count: 40)

      series = pages.series(begin: 1, left_of_current: 0, right_of_current: 3, end: 1)

      series.should eq([
        Lucky::Paginator::CurrentPage.new(pages, 1),
        Lucky::Paginator::Page.new(pages, 2),
        Lucky::Paginator::Page.new(pages, 3),
        Lucky::Paginator::Page.new(pages, 4),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 40),
      ])
    end

    it "returns the correct series when near the first page" do
      pages = build_pages(page: 2, per_page: 1, item_count: 40)

      series = pages.series(begin: 1, left_of_current: 2, right_of_current: 0, end: 1)

      series.should eq([
        Lucky::Paginator::Page.new(pages, 1),
        Lucky::Paginator::CurrentPage.new(pages, 2),
        Lucky::Paginator::Gap.new,
        Lucky::Paginator::Page.new(pages, 40),
      ])
    end
  end
end
