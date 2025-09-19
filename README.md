# LedgerApp

**TODO: Add description**

- **Transacciones**:
    - [x] Mostrar todas las transacciones
    - [x] Mostrar todas las transacciones de una cuenta especifica usando c1 como flag
        2.1: implementar flag
    - [x] Mostrar todas las transacciones de una cuenta especifica usando c1 como flag imprimiendolas en un archivo .csv
    - [x] Hacer pattern matching con el subcommand en vez de agregar un string
    - [x] bug: faltan valores por defecto para los siguientes parametros: [cuenta destino, moneda, output consola]
    - [x] Agregar utilidad a -c2 para subcomando transacciones
    - [x] Validar durante la _ del csv la existencia del tipo de transaccion
    - [x] Validar durante la conversion del csv la existencia de las monedas utilizadas en moneda_origen y moneda_destino

- **Balance**:
    - [x] Hacer necesario el flag -c1
    - [x] Obtener el balance de la cuenta dada la moneda en -m
    - [x] Formatear el resultado
    - [x] Testear manualmente con el ./ledger
    - [x] Reformatear salida de balance a ejemplificada por la catedra
    - [x] Agregar salida no estandar hacia archivos de el resultado de balance

- **Documentacion**
    - [ ] Crear mas casos de pruebas para los distintos modulos
    - [ ] Reordenar el codigo en modulos y funciones mas responsablemente
    - [ ] Documentar funciones publicas y comentar funciones privadas
    - [ ] Completar README con comandos de compilacion y fundamentos utilizados para atrapar errores ademas de documentacion para su uso 

### Errores generados/atrapados:
- una cuenta debe ser primero dada de alta antes de poder comenzar a transferirsele. Caso contrario la informacion seria inconsistente
- el valor de los balances cuando superan las 6 decimales se redondean en esta cifra, no se truncan
- los usuarios pueden tener valores negativos en su balances a modo de "deudas" en ciertas monedas


