# LedgerApp

**TODO: Add description**

- Transacciones:
[x] v1: mostrar todas las transacciones
[x] v2: mostrar todas las transacciones de una cuenta especifica usando c1 como flag
    2.1: implementar flag
[x] v3: mostrar todas las transacciones de una cuenta especifica usando c1 como flag imprimiendolas en un archivo .csv
    3.1: implementar flag


[x] bug: faltan valores por defecto para los siguientes parametros: [cuenta destino, moneda, output consola]

- Balance:
[ ] Hacer necesario el flag -c1
[ ] Obtener el balance de la cuenta dada la moneda en -m
[ ] Formatear el resultado
[ ] 


### Errores generados/atrapados:
- una cuenta debe ser primero dada de alta antes de poder comenzar a transferirsele. Caso contrario la informacion seria inconsistente
- una cuenta no puede ser dada de alta multiples veces. Caso contrario la informacion seria inconsistente
- una cuenta debe hacer un swap de las monedas que contiene en su cuenta para poder transferir en otra moneda, previamente a realizar la transferencia (debe disponer de la cantidad de la moneda a transferir en la billetera antes de poder realizar la transferencia)


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ledger_app>.

