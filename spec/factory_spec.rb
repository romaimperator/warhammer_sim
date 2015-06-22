require "spec_helper"
require "factory"

class BasicFactory
  include Factory

  factter :name, :mm_width
end

class HashFactory
  include Factory

  factter name: "halberd",
    mm_width: 20
end

describe Factory do
  describe "#initialize" do
    describe "given a hash" do
      it "will create an initializer setting the keys and values" do
        hash = HashFactory.new
        assert_equal "halberd", hash.instance_variable_get("@name")
        assert_equal 20, hash.instance_variable_get("@mm_width")
      end

      it "will define setters with the same name as the attribute" do
        hash = HashFactory.new
        hash.name("witch")
        hash.mm_width(40)
        assert_equal "witch", hash.instance_variable_get("@name")
        assert_equal 40, hash.instance_variable_get("@mm_width")
      end

      it "will define setters that return self" do
        hash = HashFactory.new
        assert_equal hash, hash.name("name")
        assert_equal hash, hash.mm_width(40)
      end
    end

    describe "given an array" do
      it "will define setters with the same name as the attribute" do
        basic = BasicFactory.new
        basic.name("witch")
        basic.mm_width(40)
        assert_equal "witch", basic.instance_variable_get("@name")
        assert_equal 40, basic.instance_variable_get("@mm_width")
      end

      it "will define setters that return self" do
        basic = BasicFactory.new
        assert_equal basic, basic.name("name")
        assert_equal basic, basic.mm_width(40)
      end
    end
  end
end

