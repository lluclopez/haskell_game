# Práctica — Juego Haskell

## Compilar
Compila con:
```
ghc --make Main.hs -o practica
```

Ejecutar en Windows:
```
.\practica.exe
```
O en Unix:
```
./practica
```

## Entrada (argumentos)
- Primer argumento: ruta al archivo del mapa (por ejemplo instancies/exemple.txt)
- Segundo argumento: tipo de controlador: `pilot` (jugador) o `ia` (inteligencia artificial)

## Instancias de prueba
Los archivos de prueba están en la carpeta `instancies/`:
- `exemple.txt` — mapa de ejemplo
- `test_seq.txt`, `test_big.txt` — mapas de prueba