require 'spec_helper'
require 'timecop'

describe Crufty::Context do
  let(:best_by) { Time.now + 30 }
  let(:expires_at) { Time.now + 60 }  
  let(:ctx) { Crufty::Context.new(best_by, expires_at) }

  describe "#initialize" do
    context "invoked with two Times" do
      let(:best_by) { Time.now - 60 }
      let(:expires_at) { Time.now + 60 }

      it "sets invoked_at to the current Time" do
        now = Time.new(2015, 10, 21, 16, 29)
        Timecop.freeze(now) do
          expect(ctx.invoked_at).to eq(now)
        end
      end
    end

    context "invoked with two DateTimes" do
      let(:best_by) { DateTime.now - 60 }
      let(:expires_at) { DateTime.now + 60 }

      it "sets invoked_at to the current DateTime" do
        now = DateTime.new(2015, 10, 21, 16, 29)
        Timecop.freeze(now) do
          expect(ctx.invoked_at).to eq(now)
        end
      end
    end

    context "invoked with a Time and a DateTime" do
      let(:best_by) { DateTime.now - 60 }
      let(:expires_at) { Time.now + 60 }

      it "raises an ArgumentError" do
        expect { ctx }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#stale?" do
    subject { ctx.stale? }

    context "when best_by is in the future" do
      let(:best_by) { Time.now + 30 }
      it { is_expected.to be(false) }
    end

    context "when best_by is in the past" do
      let(:best_by) { Time.now - 30 }
      it { is_expected.to be(true) }
    end
    
    context "when best_by is nil" do
      let(:best_by) { nil }
      it { is_expected.to be(true) }
    end
  end

  describe "#expired?" do
    subject { ctx.expired? }

    context "with a future expiration date" do
      let(:expires_at) { Time.now + 30 }
      it { is_expected.to be(false) }
    end

    context "with no expiration date" do
      let(:expires_at) { nil }
      it { is_expected.to be(false) }
    end
    
    context "with an expiration date in the past" do
      let(:expires_at) { Time.now - 30 }
      it { is_expected.to be(true) }
    end
  end  

  describe "#state" do
    subject { ctx.state }

    context "with a future expiration date" do
      let(:expires_at) { Time.now + 60 }
      
      context "and a future best by date" do
        let(:best_by) { Time.now + 30 }
        it { is_expected.to eq(:fresh) }
      end

      context "and a past best by date" do
        let(:best_by) { Time.now - 30 }
        it { is_expected.to eq(:stale) }
      end
    end

    context "with a past expiration date" do
      let(:expires_at) { Time.now - 30 }
      it { is_expected.to eq(:expired) }
    end
  end   
end
