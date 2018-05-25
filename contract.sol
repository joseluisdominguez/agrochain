pragma solidity ^0.4.20;

contract tmpContract {
    address owner;
    constructor() public {
        owner = msg.sender;
    }
    
    function getAddress() public returns(address) {
        return owner;
    }
}

contract AgroChain {
    enum categorias {
        primera, segunda, tercera
    }
    struct Fruta {
        categorias categoria;
        uint256 peso;
    }
    struct Compra {
        categorias categoria;
        uint256 peso;
        uint256 precio;
    }
    
    
    // Direccion del owner
    address cooperativa;
    
    // Guardar lo que cada agricultor recolecta
    mapping (address => Fruta[]) public recoleccion;
    // Guardar lo que realmente ha aportado el agricultor
    //(una vez clasificado por la cooperativa)
    mapping (address => Fruta[]) public clasificados;
    mapping (bytes32 => uint256) public precioVenta;
    mapping (bytes32 => uint256) public cantidadParaVenta;//la clave va a ser el enum de la categoría
   
   
    // Dinero recaudado (Unidad fijada en céntimos de euro)
    uint256 public dineroRecaudado;
  
    // Porciento de comisión para la cooperativa
    uint256 public porcentajeCooperativa;
    
    // Guardar las transacciones de compra
    mapping(address => Compra[]) public transacciones; //clave=>valor
    
    constructor(uint256 _porcentajeCooperativa, uint256 _precioVenta1, uint256 _precioVenta2, uint256 _precioVenta3) public {
        porcentajeCooperativa = _porcentajeCooperativa;
        precioVenta[sha3(categorias.primera)] = _precioVenta1;
        precioVenta[sha3(categorias.segunda)] = _precioVenta2;
        precioVenta[sha3(categorias.tercera)] = _precioVenta3;
        cooperativa = msg.sender;
    }
    
    //kill
    function kill(address tx) public returns(address){
        // Condicion propietario
        require (msg.sender == cooperativa); 
        
        // Condición de todo vendido
        
        tmpContract tmp = tmpContract(tx);
        // Repartir el balance de todos y guardarlo en el otro S.C.
        //return tmp.getAddress();
        
        //selfdestruct(cooperativa);
    }
    
   // añadir mercancia
    function agregarMercancia(categorias _categoria, uint256 _peso) public{
        recoleccion[msg.sender].push(Fruta(_categoria, _peso));
        //añadir evento
        
    }
        
    // clasificar
    function clasificarMercancia(address _agricultor)public{
        //recoleccion[msg.sender].
        for(uint i = 0; i<recoleccion[_agricultor].length;i++){
            //quitar 3 provisionalmente
            clasificados[_agricultor].push(Fruta(
                recoleccion[_agricultor][i].categoria,
                recoleccion[_agricultor][i].peso-3
                
            ));
            
            cantidadParaVenta[sha3(recoleccion[_agricultor][i].categoria)]+=recoleccion[_agricultor][i].peso-3;
        }
    }
     
    function Comprar(categorias _categoria, uint256 _peso)public{
        // require para que no se quede el total en negativo
        require(cantidadParaVenta[sha3(_categoria)]-_peso >= 0);
        
        
        //quitamos de cantidad para venta
        cantidadParaVenta[sha3(_categoria)]-=_peso;
        //metemos en el balance
        dineroRecaudado+=precioVenta[sha3(_categoria)]*_peso;
        //registramos la transacción
        transacciones[msg.sender].push(Compra(
            _categoria,
            _peso,
            precioVenta[sha3(_categoria)]
        ));
    }
    
    function getByte32() public returns(bytes32) {
        return sha3(categorias.primera);
    }
}
    
    
