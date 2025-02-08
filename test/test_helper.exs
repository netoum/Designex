
ExUnit.start()

ExUnit.after_suite(fn _suite_result ->
  IO.puts("✅ Test suite completed!")
  File.rm_rf!("test/tmp")
end)
