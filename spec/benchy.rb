#!/usr/bin/env ruby -Ispec

require "benchmark/ips"
require_relative "factories/rank_and_file_unit_factory"

require 'inline'

class MyTest
  inline do |builder|
    builder.c "
    uint upper_file(uint upper_interval, uint right, uint mm_width, uint files) {
      upper_interval = right - upper_interval;
      uint upper = 0;
      if (upper_interval % mm_width == 0) {
        upper = upper_interval / mm_width + 1;
      } else {
        upper = upper_interval / mm_width;
      }
      if (upper > files) {
        return files;
      } else {
        return upper;
      }
    }"
    builder.c "
    uint lower_file(uint lower_interval, uint right, uint mm_width, uint files) {
      lower_interval = right - lower_interval;
      uint lower = lower_interval / mm_width;
      if (lower > 1) {
        return lower;
      } else {
        return 1;
      }
    }"
    builder.c_raw "
    static VALUE test(int argc, VALUE *argv, VALUE self) {
      ID factorial_method = rb_intern(\"factorial\");
      return rb_funcall(argv[0], factorial_method, 1, INT2FIX(5));
    }"
    builder.c_raw "
    static VALUE get_at_position(int argc, VALUE *argv, VALUE self) {
      ID sym_at = rb_intern(\"at\");
      return rb_funcall(argv[0], sym_at, 2, argv[1], argv[2]);
    }"
  end
end
t = MyTest.new()

other_units = {
  [1, 4] => ModelFactory.new.name("champ").mm_width(20).build
}
unit = RankAndFileUnitFactory.new.files(5).other_units(other_units)
  .build_positions
intervals = [[0, 20], [20, 40], [40, 60], [60, 80], [80, 100]]
champ = ModelFactory.new.mm_length(20).mm_width(40).build

Benchmark.ips do |x|
  #x.report("other") { unit.targets_in_intervals2(t, intervals) }
  #x.report("targets_in_intervals") { unit.targets_in_intervals(intervals) }
  x.report("compute_ruby") { unit.compute_occupation(champ) }
  x.report("compute_c") { unit.compute_occupation2(champ) }
  x.compare!
end

#p t.upper_file(20, 100, 20, 5) == r.upper_file(20, 100, 20, 5)

#Benchmark.ips do |x|
#  x.report("c") { t.upper_file(20, 100, 20, 5) }
#  x.report("ruby") { r.upper_file(20, 100, 20, 5) }
#  x.compare!
#end
