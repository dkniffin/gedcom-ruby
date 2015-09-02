describe Parser do
  GEDCOMS = File.dirname(__FILE__)+"/gedcoms"
  SIMPLE = "#{GEDCOMS}/simple.ged"

  let(:parser) { GEDCOM::Parser.new }
  let(:tag_count) { {:all => 0} }

  let(:harmless_cb_lambda) { lambda{|data| 1 + 1} }

  before(:each) do
    parser.before :any do |data|
      tag = parser.context.join('_')
      tag_count[tag] ||= 0
      tag_count[tag] += 1
      tag_count[:all] += 1
    end
  end

  describe ".new" do
    it "can be called with block" do
      parser = GEDCOM::Parser.new do
        before 'INDI' do
        end
      end
    end
  end


  describe "#before" do
    it "adds a callback to the :before stack" do
      parser.before(:any, &harmless_cb_lambda)
      expect(parser.callbacks[:before]).to include(&harmless_cb_lambda)
    end
  end

  describe "#after" do
    it "adds a callback to the :before stack" do
      parser.after(:any, &harmless_cb_lambda)
      expect(parser.callbacks[:after]).to include(&harmless_cb_lambda)
    end


    let(:correct_conc) do
      "This is a really long body of text that should be wrapped in " +
      "the middle of a word. The resulting data object (string) should " +
      "not include that newline, but instead should just concatenate the " +
      "two pieces of the word together. It should also correctly handle " +
      "breaks on spaces. It should also handle blank lines."
    end
    it "handles CONC correctly" do
      # Continue the text, with no newline or space in between
      parser.after ['SUBM', 'TEXT'] do |text|
        expect(text).to eq(correct_conc)
      end

      parser.parse "#{GEDCOMS}/linewrap_conc.ged"
    end


    let(:correct_cont) do
      "This is a formatted attribute\n" +
      "with a line break in the middle.\n" +
      "Unlike CONC, the resulting string\n" +
      "should have newline characters."
    end
    it "handles CONT correctly" do
      # Continue the text, with a newline in the middle

      parser.after ['SUBM', 'TEXT'] do |text|
        expect(text).to eq(correct_cont)
      end
      parser.parse "#{GEDCOMS}/linewrap_cont.ged"
    end
  end

  describe "#parse" do
    it "can count individual tags, before and after" do
      count_before = 0
      count_after = 0
      parser.before 'INDI' do |data|
        count_before += 1
      end
      parser.after 'INDI' do |data|
        count_after += 1
      end
      parser.parse SIMPLE
      expect(count_before).to eq(3)
      expect(count_after).to eq(3)
    end

    it "unwinds all the way" do
      # TRLR indicates the end of a gedcom file
      after_trlr = false
      parser.after 'TRLR' do
        after_trlr = true
      end
      parser.parse SIMPLE
      expect(after_trlr).to eq(true)
    end


    it "uses :any as default" do
      parser.parse SIMPLE
      expect(tag_count[:all]).to eq(47)
      expect(tag_count['INDI']).to eq(3)
      expect(tag_count['FAM']).to eq(1)
      expect(tag_count['FAM_MARR_DATE']).to eq(1)
    end

    it "handles empty gedcom" do
      parser.parse "\n"
      expect(tag_count[:all]).to eq(0)
    end
  end
end
