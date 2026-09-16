# Alke Wallet | Base de Datos Relacional

Proyecto académico desarrollado para el módulo **Fundamentos de Bases de Datos Relacionales**.

## Objetivo

Diseñar e implementar una base de datos relacional para una billetera virtual. El sistema permite administrar usuarios, monedas y transferencias, manteniendo la integridad de la información mediante claves, restricciones y transacciones.

## Tecnologías

- SQL
- MySQL 8
- Motor InnoDB
- dbdiagram.io (modelo entidad-relación)

## Modelo de datos

| Tabla | Descripción | Clave primaria |
| --- | --- | --- |
| `moneda` | Catálogo de monedas habilitadas en la wallet | `currency_id` |
| `usuario` | Usuarios registrados y su saldo actual | `user_id` |
| `transaccion` | Historial de transferencias entre usuarios | `transaction_id` |

### Relaciones

- Una **moneda** puede estar asociada a muchos usuarios.
- Una **moneda** puede utilizarse en muchas transacciones.
- Un **usuario** puede enviar muchas transacciones.
- Un **usuario** puede recibir muchas transacciones.

La tabla `transaccion` contiene dos claves foráneas hacia `usuario`: `sender_user_id` para el emisor y `receiver_user_id` para el receptor.

## Estructura del repositorio

```text
.
├── AlkeWallet.sql
├── diagrama-er.dbml
└── README.md
```

## Ejecución

1. Abre una instancia compatible con **MySQL 8**, por ejemplo SQLOnline.
2. Copia y ejecuta el contenido de `AlkeWallet.sql`.
3. El script crea la base de datos, las tablas, restricciones, índices y datos de prueba.
4. Ejecuta las consultas incluidas al final del archivo para comprobar los resultados.

> Si la plataforma no permite ejecutar `CREATE DATABASE`, crea o selecciona la base de datos manualmente y ejecuta el resto del script.

## Integridad de datos

El diseño contempla los siguientes mecanismos:

- Claves primarias para identificar cada registro.
- Claves foráneas para asegurar la integridad referencial.
- Restricción `UNIQUE` para impedir correos o nombres de moneda duplicados.
- Restricciones `CHECK` para impedir saldos negativos, importes no válidos y transferencias al mismo usuario.
- Índices compuestos para facilitar consultas del historial por emisor, receptor y fecha.
- Motor InnoDB para soportar transacciones.

## ACID aplicado

| Propiedad | Aplicación en Alke Wallet |
| --- | --- |
| Atomicidad | La actualización de ambos saldos y el registro de la transferencia se realizan juntos mediante `START TRANSACTION` y `COMMIT`. |
| Consistencia | Las claves, restricciones y validaciones protegen las reglas del modelo. |
| Aislamiento | InnoDB controla la ejecución concurrente de las transacciones. |
| Durabilidad | Una vez confirmado con `COMMIT`, el cambio queda persistido por el motor de base de datos. |

## Consultas implementadas

- Moneda elegida por un usuario específico.
- Lista de todas las transacciones registradas.
- Historial enviado y recibido por un usuario determinado.
- Actualización del correo electrónico de un usuario.
- Eliminación de una transacción.
- Ejemplos controlados con `COMMIT` y `ROLLBACK`.

## Autor

**Marcel Navarrete Monrroy**  
Proyecto académico — Alke Wallet
