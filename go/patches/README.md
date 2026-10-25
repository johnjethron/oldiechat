# Parches al runtime de Go

Aquí van los parches propios a Go (por ejemplo, un respaldo para una llamada al
sistema que no existe en kernels Linux 3.0). `Dockerfile.armv7` los aplica en
orden alfabético sobre el Go de `versions.env`, después del parche de musl que
trae nchat. Cómo encontrar la llamada que falla y escribir el parche:
`MAINTAINING.md`, sección "Si Go deja de funcionar en kernels antiguos".

Nombre: `<número>-<descripción>.patch`, aplicable con `patch -p1 -d $GOROOT`.
