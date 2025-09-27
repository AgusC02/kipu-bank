KipuBank es un contrato inteligente en Solidity que permite a los usuarios interactuar en su propia bóveda personal, depositando y retirando tokens.
El contrato incluye un registro del número de depósitos y retiros, limites para los retiros y un límite global de depósitos.

Además:
- Transferencias seguras con call.
- Emisión de eventos en depósitos y retiros.
- Uso de errores personalizados.
- Implementación de receive y fallback para aceptar ETH enviado directamente.

---
Para clonar el proyecto se debe acceder al link de gitHub del mismo, descargar el archivo KipuBank.sol y luego desde un IDE que soporte Solidity abrir el archivo descargado, compilarlo y ejecutarlo.
Desplegar especificando el `bankCap` en el constructor: constructor(uint256 _bankCap)

Contrato deployado:
https://sepolia.etherscan.io/address/0xdD5f7d6947f617830889D443A97bC8224EA632C6
