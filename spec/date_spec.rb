describe Date do
  let(:date) { GEDCOM::Date.new("1 APRIL 2008") }
  let(:date_range_from) { GEDCOM::Date.new("FROM APRIL 2007 TO JUNE 2008") }
  let(:date_range_between) { GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008") }
  let(:date_bc) { GEDCOM::Date.new("25 JANUARY 1 BC") }
  let(:date_year_span) { GEDCOM::Date.new("1 APRIL 2007/08") }


  ## ! Could definitely stand to beef this test up. About, Estimated, etc.
  ##   Lot's of flags to test.
  it "makes flags available" do
    expect(date_range_from.format & GEDCOM::Date::FROMTO).to_not eq(0)
    expect(date_range_between.format & GEDCOM::Date::BETWEEN).to_not eq(0)
  end

  it "does comparison" do
    expect(date <=> date_bc).to eq(1)
    expect(date_bc <=> date).to eq(-1)
    expect(date <=> date).to eq(0)
  end

  it "gets first and last date from ranges" do
    expect(date_range_from.is_range?).to be(true)
    expect(date_range_between.is_range?).to eq(true)

    expect(date_range_from.first.nil?).to eq(false)
    expect(date_range_from.last.nil?).to eq(false)
    expect(date_range_between.first.nil?).to eq(false)
    expect(date_range_between.last.nil?).to eq(false)

    expect(date_range_from.first <=> date_range_from.last).to eq(-1)
    expect(date_range_between.first <=> date_range_between.last).to eq(-1)
  end

  # to_s currently works differently in the Ruby vs. C extension
  # code, therefore this test is failing (in C)
  it "converts to string" do
    expect(date.to_s).to eq("1 Apr 2008")
    expect(date_range_from.to_s).to eq("from Apr 2007 to Jun 2008")
    expect(date_range_between.to_s).to eq("bet 1 Jan 1970 and 1 Apr 2008")
    expect(date_bc.to_s).to eq("25 Jan 1 BC")
    expect(date_year_span.to_s).to eq("1 Apr 2007-8")
  end
end
