describe Parser do
  GEDCOMS = File.dirname(__FILE__)+"/gedcoms"
  SIMPLE = "#{GEDCOMS}/simple.ged"

  let(:parser) { GEDCOM::Parser.new }
  let(:tag_count) { {:all => 0} }

  let(:callback) { lambda{|data| } }

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
      parser.before(:any, callback)
      expect(parser.callbacks[:before].values.flatten).to include(callback)
    end
    describe ":any" do
      it "is called for each line" do
        parser.before(:any, callback)
        expect(callback).to receive(:call).exactly(5).times
        parser.parse "#{GEDCOMS}/5_lines.ged"
      end
    end

    # I have no clue why this isn't working. It puts out the "meh" five times,
    # but for some reason rspec doesn't think some_method has been called
    # context "with a custom parser" do
    #   before do
    #     class CustomParser < GEDCOM::Parser
    #       def after_initialize
    #         before(:any, :some_method)
    #       end
    #       def some_method(data)
    #         puts "meh"
    #       end
    #     end
    #   end
    #   let(:parser) { CustomParser.new }
    #
    #   it "can be called with a method" do
    #     expect(parser).to receive(:some_method).exactly(5).times
    #     parser.parse "#{GEDCOMS}/5_lines.ged"
    #   end
    # end
  end

  describe "#after" do
    it "adds a callback to the :before stack" do
      parser.after(:any, callback)
      expect(parser.callbacks[:after].values.flatten).to include(callback)
    end

    describe ":any" do
      it "is called for each line" do
        parser.after(:any, callback)
        expect(callback).to receive(:call).exactly(5).times
        parser.parse "#{GEDCOMS}/5_lines.ged"
      end
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
    it "can count tags, using before" do
      parser.before(['INDI'], callback)
      expect(callback).to receive(:call).exactly(3).times
      parser.parse "#{GEDCOMS}/3_indis.ged"
    end

    it "can count tags, using after" do
      parser.after(['INDI'], callback)
      expect(callback).to receive(:call).exactly(3).times
      parser.parse "#{GEDCOMS}/3_indis.ged"
    end


    it "unwinds all the way" do
      # TRLR indicates the end of a gedcom file
      parser.after('TRLR', callback)
      expect(callback).to receive(:call).once
      parser.parse SIMPLE
    end

    it "handles empty gedcom" do
      parser.before(:any, callback)
      parser.parse "\n"
      expect(callback).to_not receive(:call)
    end

    it "handles windows line endings" do
      parser.before(['INDI'],callback)
      expect(callback).to receive(:call).with('@I1@')
      parser.parse "0 @I1@ INDI\r\n"
    end
  end
end
