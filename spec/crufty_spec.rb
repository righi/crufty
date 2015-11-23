require 'spec_helper'

shared_examples_for "non-stale, unexpired code" do
  subject { counter.increment }

  it "does not raise an error" do
    expect { subject }.to_not raise_error
  end

  it "does not warn of any problems" do
    expect(Crufty.logger).to_not receive(:warn)
    subject
  end

  it "runs the crufty block" do
    expect { subject }.to change{ counter.count }.from(0).to(1)
  end
end

shared_examples_for "stale, unexpired code" do
  subject { counter.increment }

  it "does not raise an error" do
    expect { subject }.to_not raise_error
  end

  it "warns that the code will expire soon" do
    expect(Crufty.logger).to receive(:warn).once

    subject
  end    

  it "runs the crufty block" do
    expect { subject }.to change{ counter.count }.from(0).to(1)
  end
end

shared_examples_for "expired code" do
  subject { counter.increment }

  it "raises an error without running the crufty block" do
    expect { subject }.to raise_error(Crufty::CodeExpired).and change{ counter.count }.by(0)
  end
end

describe Crufty do
  let(:counter)     { CruftyCounter.new(stale_at, expires_at) }

  context "unexpired code" do
    context "that never expires" do
      let(:expires_at) { nil }

      # Example: crufty(best_by: tomorrow) { ... }
      context "and isn't stale" do
        let(:stale_at) { Time.now + 30 }
        it_behaves_like "non-stale, unexpired code"
      end

      # Example: crufty(best_by: yesterday) { ... }
      context "and is stale" do
        let(:stale_at) { Time.now - 30 }
        it_behaves_like "stale, unexpired code"
      end

      # Example: crufty { ... }
      context "and was always stale" do
        let(:stale_at) { nil }
        it_behaves_like "stale, unexpired code"
      end
    end

    context "that has an expiration date" do
      let(:expires_at) { Time.now + 60 }

      # Example: crufty(best_by: tomorrow, expires: day_after_tomorrow) { ... }
      context "and isn't stale" do
        let(:stale_at) { Time.now + 30 }
        it_behaves_like "non-stale, unexpired code"
      end

      # Example: crufty(best_by: yesterday, expires: tomorrow) { ... }
      context "and is stale" do
        let(:stale_at) { Time.now - 30 }
        it_behaves_like "stale, unexpired code"
      end

      # Example: crufty(expires: tomorrow) { ... }
      context "and was always stale" do
        let(:stale_at) { nil }
        it_behaves_like "stale, unexpired code"
      end
    end
  end

  context "expired code" do
    let(:expires_at) { Time.now - 60 }

    # Example: crufty(expires: yesterday) { ... }
    context "that was always stale" do
      let(:stale_at) { nil }
      it_behaves_like "expired code"
    end

    # Example: crufty(best_by: 2.days.ago, expires: yesterday) { ... }
    context "that had a stale date" do
      let(:stale_at) { Time.now - 30 }
      it_behaves_like "expired code"
    end
  end
end