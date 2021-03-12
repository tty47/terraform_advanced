# Qué hace el módulo
- Crea pareja de claves
- Las añade a Amazon
- Las exporta a unos ficheros
- Las devuelve al usuario como outputs

# Que variables requiere el módulo

| Variable | Descripción | Obligatoria | Valor por defecto | 
| --- | --- | --- | --- | 
| longitud_clave_rsa | Longitud en bytes de la clave | x | 4096 |
| id_clave | Identificador de la clave en Amazon y en el nombre del fichero | √ | - |

# Cual es la salida del módulo
| Output | Descripción |
| --- | --- |
| privada | Contiene el PEM de la clave privada |
| publica | Contiene el PEM de la clave publica |

Adicionalmente le genera unos ficheros llamados:
- **<id_clave>_pri.pem**: Con el PEM de la clave privada
- **<id_clave>_pub.pem**: Con el PEM de la clave publica

# Ejemplo de uso:

``` terraform
module "claves" {
    longitud_clave_rsa = 4096
    id_clave = <AQUI PON TU ID>
}
```