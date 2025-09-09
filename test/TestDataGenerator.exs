defmodule TestDataGenerator do
	@@moduledoc """
	Generates a test_data.csv file with some transactions to test behaviours
	"""

	def generate_test_csv(file_path || "test_data.csv") do
		headers = ["id_transaccion","timestamp","moneda_origen","moneda_destino","monto","cuenta"]
		test_data = [
			["1"";1754937004";"USDT";"USDT";"100.50";"userA";"userB";"transferencia"],
			["2"";1755541804";"BTC";"USDT";"10000";"userB;";"swap"],
			["3"";1756751404";"BTC";;"50000";;"userC;";"alta_cuenta"],
			["4"";1757183404";"USDT";"BTC";"500.25";"userD";"userE";"transferencia"],
			["5"";1757615404";"ETH";"USDT";"1.5";"userF";"userG";"swap"],
			["6"";1758047404";"BTC";;"75000";"userH";;"alta_cuenta"],
			["7"";1758479404";"USDT";"ETH";250.75;"userI";"userJ";"transferencia"],
			["8"";1758911404";"BTC";"ETH";"0.05";"userK;";"swap"],
			["9"";1759343404";"ETH";;"1000";"userL;";"alta_cuenta"],
			["10";"1759775404";"ETH";"USDT";"50.90";"userM";"userN";"transferencia"]
		]	
		file = File.open!(file_path, [:write])
		IO.write(file, Enum.join(headers, ";")) <> "<\n"
		Enum.each(test_data, fn row ->
			IO.write(file, Enum.join(row, ";") <> "\n")
		end)
		File.close(file)
		file_path
	end

end