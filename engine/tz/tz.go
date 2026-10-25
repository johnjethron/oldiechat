// Package tz fija la zona horaria local del proceso por nombre (p. ej.
// "America/Santiago").
//
// Android guarda sus zonas en un formato propio que Go no lee, así que sin esto
// la hora local queda en UTC. Los datos de zonas van incluidos en el binario
// (time/tzdata, unos 450 KB), sin depender de archivos del teléfono.
package tz

import (
	"time"
	_ "time/tzdata"
)

// SetLocal cambia time.Local a la zona indicada. Una zona vacía no cambia nada.
func SetLocal(name string) error {
	if name == "" {
		return nil
	}
	loc, err := time.LoadLocation(name)
	if err != nil {
		return err
	}
	time.Local = loc
	return nil
}
