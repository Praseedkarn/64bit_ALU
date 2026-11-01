include RBA

layout = Layout.new

config = LEFDEFReaderConfiguration.new
config.lef_files = [
  ENV["TECH_LEF"],
  ENV["CELL_LEF"]
]

layout.read_lef_with_def(ENV["DEF_FILE"], config)

puts "Cells: #{layout.cells.size}"
puts "Top cell: #{layout.top_cell.name}"
puts "DBU: #{layout.dbu}"
