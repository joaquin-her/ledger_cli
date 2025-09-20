# LedgerApp

Aplicacion de linea de comandos para manejar transacciones entre cuentas y obtener balances en distintas monedas. Utiliza archivos .csv para leer las transacciones y las monedas disponibles.

## Overview
El programa luego de ser compilado puede ser ejecutado desde la terminal con el comando `./ledger` seguido de los distintos flags y subcomandos.


## Instalacion

- Clonar el repositorio
- Instalar [Elixir](https://elixir-lang.org/install.html)
- En la terminal, dentro de la carpeta del proyecto, correr `mix deps.get` para instalar las dependencias
- Correr `mix escript.build` para compilar el proyecto y generar el ejecutable `ledger`

### Syntaxis Basica
```bash
./ledger <subcommand> [options]
```
- **Flags comunes**:
    - -t: archivo de transacciones (por defecto transacciones.csv)
    - -o: archivo de salida (por defecto consola)
    - -m: moneda (por defecto all)
    - -c1: usa una cuenta origen especifica


## Modo de uso
- **Transacciones**:
- Es el comando por defecto cuando se hace ``` ./ledger ```. Muestra todas las transacciones de el archivo transacciones.csv (por defecto) en consola.
- Permite para modificar su comportamiento el uso de los siguientes flags con la adicion de un parametro:
    - -c1: mostrar todas las transacciones de una cuenta especifica 
    - -c2: mostrar todas las transacciones hacia una cuenta especifica
    - -m: mostrar todas las transacciones en una moneda especifica
    - -t: utilizar un archivo de transacciones distinto al por defecto
    - -o: escribir el resultado en un archivo en vez de en consola
- **Balance**:
- Tiene como **necesario** el flag -c1
- Permite btener el balance de la cuenta dada la moneda en -m, por defecto "all". La moneda debe estar en el archivo de monedas.csv
- Su resultado puede ser escrito en consola (por defecto) o en un archivo con -o
- Se puede utilizar un archivo de transacciones distinto al por defecto con -t
#### Ejemplos de uso:
```bash
# List all transactions
./ledger transacciones

# List transactions from specific account
./ledger transacciones -c1 userA

# List transactions between two accounts
./ledger transacciones -c1 userA -c2 userB

# Use custom transaction file and save to output
./ledger transacciones -t test_data.csv -c1 userB -o result.csv
```

## Detalles de implementacion

### Module Organization
- **CLI Module**: Command-line interface and argument parsing
- **Commands Module**: Business logic for transactions and balance calculations  
- **Database Module**: CSV file operations and data persistence
- **Transaction Module**: Core transaction data structures

### Errores generados/atrapados:
Los errores son atrapados en distintos niveles y devueltos al usuario con distintos niveles de detalle:
- **CSV_Database**: 
    - errores durante la lectura o escritura de archivos: {:error, descripcion} donde *descripcion* es un string que explica el error proporcionada por File 
    - errores durante la inicializacion de estructuras del modelo: {:error, linea} donde *linea* es un int de la linea del csv que genero el error
- **Commandos**:
    - errores de validacion de argumentos: {:error, descripcion} donde *descripcion* es un string que explica el error
    - errores de logica de negocio: {:error, id_transaccion} donde id_transaccion es el id de la transaccion que genero el error
- **CLI**:
    - errores de argumentos y flags: {:error, descripcion} donde *descripcion* es un string que explica el error 

### Aclaraciones
- una cuenta debe ser primero dada de alta antes de poder comenzar a generarsele un balance
- el valor de los balances cuando superan las 6 decimales se redondean en esta cifra, no se truncan
- los usuarios pueden tener valores negativos en su balances a modo de "deudas"
- el balance entre dos usuarios no es un caso contemplado y genera un error {:error, descripcion}

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)

