describe DatePart do
  let(:date) { GEDCOM::Date.new("1 APRIL 2008") }
  let(:date_range_from) { GEDCOM::Date.new("FROM APRIL 2007 TO JUNE 2008") }
  let(:date_range_between) { GEDCOM::Date.new("BETWEEN 1 JANUARY 1970 AND 1 APRIL 2008") }
  let(:date_bc) { GEDCOM::Date.new("25 JANUARY 1 BC") }
  let(:date_year_span) { GEDCOM::Date.new("1 APRIL 2007/08") }
  let(:nonstandard) { GEDCOM::Date.safe_new("FIRST DAY OF 2008") }
  let(:phrase) { GEDCOM::Date.safe_new("(independance day)") }

  it "makes date type and flags available" do
    expect(date.first.compliance | GEDCOM::DatePart::NONE).to eq(0)
    #expect(nonstandard.first.compliance & GEDCOM::DatePart::NONSTANDARD).to_not eq(0)
    expect(phrase.first.compliance & GEDCOM::DatePart::PHRASE).to_not eq(0)

    expect(date_range_from.first.calendar | GEDCOM::DateType::DEFAULT).to eq(0)
    expect(date_range_from.last.calendar | GEDCOM::DateType::DEFAULT).to eq(0)
  end

  it "finds days" do
    expect(date.first.has_day?).to eq(true)
    expect(date.first.day).to eq(1)

    expect(date_range_between.first.has_day?).to eq(true)
    expect(date_range_between.first.day).to eq(1)

    expect(date_range_between.last.has_day?).to eq(true)
    expect(date_range_between.last.day).to eq(1)

    expect(date_bc.first.has_day?).to eq(true)
    expect(date_bc.first.day).to eq(25)
  end

  it "finds months" do
    expect(date.first.has_month?).to eq(true)
    expect(date.first.month).to eq(4)

    expect(date_range_between.first.has_month?).to eq(true)
    expect(date_range_between.first.month).to eq(1)

    expect(date_range_between.last.has_month?).to eq(true)
    expect(date_range_between.last.month).to eq(4)

    expect(date_bc.first.has_month?).to eq(true)
    expect(date_bc.first.month).to eq(1)
  end

  it "finds years" do
    expect(date.first.has_year?).to eq(true)
    expect(date.first.year).to eq(2008)

    expect(date_range_between.first.has_year?).to eq(true)
    expect(date_range_between.first.year).to eq(1970)

    expect(date_range_between.last.has_year?).to eq(true)
    expect(date_range_between.last.year).to eq(2008)

    expect(date_bc.first.has_year?).to eq(true)
    expect(date_bc.first.year).to eq(1)
  end

  it "finds the epoch" do
    expect(date.first.epoch).to eq("AD")
    expect(date_bc.first.epoch).to eq("BC")
  end

  it "finds year span" do
    expect(date_year_span.first.has_year_span?).to eq(true)
    expect(date.first.has_year_span?).to eq(false)
  end

  # to_s currently works differently in the Ruby vs. C extension
  # code, therefore this test is failing (in C)
  it "converts to string" do
    expect(date.first.to_s).to eq("1 Apr 2008")

    expect(date_range_from.first.to_s).to eq("Apr 2007")
    expect(date_range_from.last.to_s).to eq("Jun 2008")

    expect(date_range_between.first.to_s).to eq("1 Jan 1970")
    expect(date_range_between.last.to_s).to eq("1 Apr 2008")

    expect(date_bc.first.to_s).to eq("25 Jan 1 BC")

    expect(date_year_span.to_s).to eq("1 Apr 2007-8")
  end

end
