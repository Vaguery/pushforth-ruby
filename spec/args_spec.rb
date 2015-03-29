require 'rspec'
require_relative '../lib/push-forth'
include PushForth

describe "setting arguments in the interpreter" do
  it "should be possible to set the arguments using a second initialization parameter" do
    pf = PushForthInterpreter.new([[:args],1,2],[:foo,[false,8.1]])
    expect(pf.get_args).to eq [:foo, [false, 8.1]]
  end

  it "should default to an empty list" do
    expect(PushForthInterpreter.new().get_args).to eq []
  end
end

describe ":args instruction" do
  it "should be a recognized instruction" do
    expect(PushForthInterpreter.new.instruction?(:args)).to be true
  end

  it "should push the List containing all the args onto the stack" do
    pf = PushForthInterpreter.new([[:args],1,2],[false,true])
    expect(pf.step!.stack).to eq [[], false, true, 1, 2]
  end

  it "should be fine even when no arguments have been set" do
    pf = PushForthInterpreter.new([[:args],1,2])
    expect(pf.step!.stack).to eq [[], 1, 2]
  end
end
