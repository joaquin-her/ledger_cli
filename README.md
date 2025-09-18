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
[ ] Agregar utilidad a -c2 para subcomando transacciones
[ ] Validar durante la conversion del csv la existencia de las monedas utilizadas en moneda_origen y moneda_destino

- Balance:
[x] Hacer necesario el flag -c1
[x] Obtener el balance de la cuenta dada la moneda en -m
[x] Formatear el resultado
[x] Testear manualmente con el ./ledger
[ ] Reformatear salida de balance a ejemplificada por la catedra
[ ] Agregar salida no estandar hacia archivos de el resultado de balance
[ ] Agregar utilidad a -c2 para subcomando balance donde se genere un balance entre esas dos cuentas (util para observar direccion de las transferencias)

[ ] Crear mas casos de pruebas para los distintos modulos
[ ] Reordenar el codigo en modulos y funciones mas responsablemente


### Errores generados/atrapados:
- una cuenta debe ser primero dada de alta antes de poder comenzar a transferirsele. Caso contrario la informacion seria inconsistente
- el valor de los balances cuando superan las 6 decimales se redondean en esta cifra, no se truncan
- los usuarios pueden tener valores negativos en su balances a modo de "deudas"


Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/ledger_app>.

