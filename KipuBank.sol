// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title Contrato KipuBank
 * @author Agustín Cerdá
 * @notice Cada usuario puede depositar y retirar ETH de su propia bóveda personal.
 */

contract KipuBank {
	/** VARIABLES */

	///@notice mapping que almacena el balance de cada usuario
	mapping(address user => uint256 amount) private s_balances;

	///@notice monto mínimo aceptado para retiro
	uint256 public immutable MIN_RETIRO = 0.001 ether;
    ///@notice monto máximo aceptado para retiro
    uint256 public immutable MAX_RETIRO = 10 ether;
    ///@notice capacidad máxima del banco
    uint256 public immutable bankCap;
    ///@notice total de depósitos realizados
    uint256 public totalDeposits;
    ///@notice total de retiros realizados
    uint256 public totalWithdrawals;

    /*//////////////////////////////////////////////////////////////
                                Eventos
    //////////////////////////////////////////////////////////////*/

    ///@notice evento emitido cuando se realiza un depósito
    event Deposit_DepositReceived(address indexed user, uint256 amount);
    /// @notice evento emitido cuando se realiza un retiro
    event Withdraw_WithdrawExecuted(address indexed user, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                                Errores
    //////////////////////////////////////////////////////////////*/

    /// @notice Error lanzado cuando el saldo es insuficiente para la operación
    error InsufficientBalance(uint256 requested, uint256 available);
    /// @notice Error lanzado cuando una transferencia falla
    error TransferFailed(bytes errorData);
    /// @notice Error lanzado cuando se intenta retirar menos del mínimo permitido
    error AmountTooSmall(uint256 requested, uint256 minAllowed);
    /// @notice Error lanzado cuando se intenta retirar más de lo máximo permitido
    error AmountTooLarge(uint256 requested, uint256 maxAllowed);
    /// @notice Error lanzado cuando se intenta depositar y se supera la capacidad del banco
    error DepositLimitReached(uint256 requestedTotal, uint256 bankCap);


    /* CONSTRUCTOR */
    constructor(uint256 _bankCap) {
         bankCap = _bankCap;    // durante el despliegue
    }

    /*//////////////////////////////////////////////////////////////
                                Funciones
    //////////////////////////////////////////////////////////////*/

    receive() external payable {
        _deposit(msg.sender, msg.value);
    }  

    fallback() external payable {
        _deposit(msg.sender, msg.value);
    }

    /// @notice Deposita ETH en la bóveda personal del usuario
    function deposit() external payable {
      if (address(this).balance + msg.value > bankCap) {
            revert DepositLimitReached(address(this).balance + msg.value, bankCap);
        }
        _deposit(msg.sender, msg.value);
    }

    /// @notice Retira ETH de la bóveda personal del usuario
    function withdraw(uint256 amount) external {
        if (amount < MIN_RETIRO) { revert AmountTooSmall(amount, MIN_RETIRO);}
        if (amount > MAX_RETIRO) { revert AmountTooLarge(amount, MAX_RETIRO);}
        if (s_balances[msg.sender] < amount) {
            revert InsufficientBalance(amount, s_balances[msg.sender]);
        }

        s_balances[msg.sender] -= amount;
        totalWithdrawals += 1;   
        emit Withdraw_WithdrawExecuted(msg.sender, amount);

        _transferEth(payable(msg.sender), amount);
    }

    /*//////////////////////////////////////////////////////////////
                                Private
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposito en el banco personal
    function _deposit(address user, uint256 amount) private {
        s_balances[user] += amount;
        totalDeposits += 1;   
        emit Deposit_DepositReceived(user, amount);
    }

    /// @notice Transferencia de ETH a la dirección personal
    function _transferEth(address payable to, uint256 amount) private {
        (bool success, bytes memory error) = to.call{value: amount}("");
        if (!success) {
            revert TransferFailed(error);
        }
    }



    /*//////////////////////////////////////////////////////////////
                                View
    //////////////////////////////////////////////////////////////*/

    /// @notice Devuelve el saldo de la bóveda de un usuario
    function getBalance(address user) external view returns (uint256) {
        return s_balances[user];
    }
}