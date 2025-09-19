ExUnit.start()
# Helper functions para los tests
defmodule TestHelpers do
  def create_temp_csv(content, filename \\ "temp_test.csv") do
    File.write!(filename, content)
    filename
  end

  def cleanup_temp_file(filename) do
    if File.exists?(filename) do
      File.rm!(filename)
    end
  end
end
