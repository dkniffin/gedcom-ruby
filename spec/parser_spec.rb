describe Parser do
  GEDCOMS = File.dirname(__FILE__)+"/gedcoms"
  SIMPLE = "#{GEDCOMS}/simple.ged"

  before(:each) do
    @tag_count = { :all => 0 }
    @parser = GEDCOM::Parser.new
    @parser.before :any do |tag,data|
      tag = tag.join('_')
      @tag_count[tag] ||= 0
      @tag_count[tag] += 1
      @tag_count[:all] += 1
    end
  end

  it "can be initialized with block" do
    parser = GEDCOM::Parser.new do
      before 'INDI' do
      end
    end
  end

  it "can count individual tags, before and after" do
    count_before = 0
    count_after = 0
    @parser.before 'INDI' do |data|
      count_before += 1
    end
    @parser.after 'INDI' do |data|
      count_after += 1
    end
    @parser.parse SIMPLE
    count_before.should == 3
    count_after.should == 3
  end

  it "should auto-concatenate text" do
    @parser.after %w(SUBM NAME ADDR) do |text|
      text.should == "Submitters address\naddress continued here"
    end
  end

  it "should unwind all the way" do
    after_trlr = false
    @parser.after 'TRLR' do
      after_trlr = true
    end
    @parser.parse SIMPLE
    after_trlr.should == true
  end


  it "should use :any as default" do
    @parser.parse SIMPLE
    @tag_count[:all].should == 47
    @tag_count['INDI'].should == 3
    @tag_count['FAM'].should == 1
    @tag_count['FAM_MARR_DATE'].should == 1
  end

  it "should handle empty gedcom" do
    @parser.parse "\n"
    @tag_count[:all].should == 0
  end

  it "should parse TGC551.ged (\\r)" do
    # Should handle CONC and CONT differently
    @parser.after(["HEAD", "NOTE"]) do |data|
      expected_text = <<-EOS
This file demonstrates all tags that are allowed in GEDCOM 5.5. Here are some comments about the HEADER record and comments about where to look for information on the other 9 types of GEDCOM records. Most other records will have their own notes that describe what to look for in that record and what to hope the importing software will find.

Many applications will fail to import these notes. The notes are therefore also provided with the files as a plain-text "Read-Me" file.
EOS
      data.should =~ /^#{expected_text}/
    end
    @parser.parse "#{GEDCOMS}/TGC551.ged"
    @tag_count[:all].should == 1396
  end

  it "should parse TGC551LF.ged (\\r\\n)" do
    @parser.parse "#{GEDCOMS}/TGC551LF.ged"
    @tag_count[:all].should == 1396
  end

  it "should parse TGC55C.ged (\\r)" do
    @parser.parse "#{GEDCOMS}/TGC55C.ged"
    @tag_count[:all].should == 1420
  end

  it "should parse TGC55CLF.ged (\\r\\n) with auto-concat" do
    @parser.parse "#{GEDCOMS}/TGC55CLF.ged"
    @parser.after %w(OBJE BLOB) do |data|
      data.size.should == 458
    end
    @tag_count[:all].should == 1420
  end

  it "should parse TGC55CLF.ged (\\r\\n) without auto-concat" do
    @parser.auto_concat = false
    @parser.parse "#{GEDCOMS}/TGC55CLF.ged"
    @tag_count[:all].should == 2197
  end

end
