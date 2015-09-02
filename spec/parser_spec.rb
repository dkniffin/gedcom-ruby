describe Parser do
  GEDCOMS = File.dirname(__FILE__)+"/gedcoms"
  SIMPLE = "#{GEDCOMS}/simple.ged"

  let(:parser) { GEDCOM::Parser.new }
  let(:tag_count) { {:all => 0} }

  let(:cb_lambda) { lambda{|data| 1 + 1} }

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
    before { parser.before(:any, &cb_lambda) }

    it "adds a callback to the :before stack" do
      expect(parser.callbacks[:before]).to include(&cb_lambda)
    end
  end

  describe "#after" do
    before { parser.after(:any, &cb_lambda) }

    it "adds a callback to the :before stack" do
      expect(parser.callbacks[:after]).to include(&cb_lambda)
    end

    it "auto-concatenates text" do
      parser.after ['SUBM', 'ADDR'] do |text|
        expect(text).to eq("Submitters address\naddress continued here")
      end
      parser.parse SIMPLE
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
