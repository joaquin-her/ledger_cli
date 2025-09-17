# LedgerApp

**TODO: Add description**

- Transacciones:
[x] v1: mostrar todas las transacciones
[x] v2: mostrar todas las transacciones de una cuenta especifica usando c1 como flag
    2.1: implementar flag
[x] v3: mostrar todas las transacciones de una cuenta especifica usando c1 como flag imprimiendolas en un archivo .csv
    3.1: implementar flag
[x] Hacer pattern matching con el subcommand en vez de agregar un string

[x] bug: faltan valores por defecto para los siguientes parametros: [cuenta destino, moneda, output consola]

- Balance:
[x] Hacer necesario el flag -c1
[x] Obtener el balance de la cuenta dada la moneda en -m
[x] Formatear el resultado
[ ] Testear manualmente con el ./ledger
[ ] Crear mas casos de pruebas para los distintos modulos
[ ] Reordenar el codigo en modulos y funciones mas responsablemente


### Errores generados/atrapados:
- una cuenta debe ser primero dada de alta antes de poder comenzar a transferirsele. Caso contrario la informacion seria inconsistente
- el valor de los balances cuando superan las 6 decimales se redondean en esta cifra, no se truncan
- los usuarios pueden tener valores negativos en su balances a modo de "deudas"


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ledger_app>.

