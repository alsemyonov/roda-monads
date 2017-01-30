
SimpleCov.start do
  add_filter '/spec/'
  add_group('Missing') { |src| src.covered_percent < 100 }
  add_group('Covered') { |src| src.covered_percent == 100 }
end
