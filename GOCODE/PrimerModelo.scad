// ===================================================
// BASE "GoCode" PARA IMPRESIÓN 3D (VERSIÓN DEFINITIVA)
// ===================================================

// --- Dimensiones Principales (en mm) ---
ancho_total       = 80;    // Largo total (Eje X)
profundidad_total = 60;    // Profundidad total (Eje Y)
altura_total      = 35;    // Altura total de 3,5 cm (Eje Z)
radio_esquinas    = 4;     // Redondeo de las 4 esquinas verticales
radio_superior    = 2.5;   // Redondeo del borde superior

// --- Especificaciones de Ranuras ---
largo_ranura       = 70;   // Largo de cada ranura
ancho_ranura       = 2.4;  // Ancho de cada ranura
profundidad_ranura = 20;   // Profundidad de 2 cm (20 mm)
cant_ranuras       = 3;    // Cantidad de ranuras
separacion_ranuras = 15;   // Distancia entre centros de ranuras

// --- Texto en Relieve ---
texto_logo     = "GoCode";
relieve_texto  = 1;        // Sobresale exactamente 1 mm hacia el frente
tamano_fuente  = 11;       // Altura de letra en mm

$fn = 80; // Resolución y suavizado de curvas

// --- Módulos de Geometría ---

module cuerpo_base() {
    hull() {
        for (x = [radio_esquinas, ancho_total - radio_esquinas]) {
            for (y = [radio_esquinas, profundidad_total - radio_esquinas]) {
                // Cilindro vertical principal
                translate([x, y, 0])
                    cylinder(r = radio_esquinas, h = altura_total - radio_superior);
                
                // Borde suave redondeado en la tapa superior
                translate([x, y, altura_total - radio_superior])
                    rotate_extrude()
                        translate([radio_esquinas - radio_superior, 0, 0])
                            circle(r = radio_superior);
            }
        }
    }
}

module ranuras() {
    y_inicio = (profundidad_total - (cant_ranuras - 1) * separacion_ranuras) / 2;
    for (i = [0 : cant_ranuras - 1]) {
        y_pos = y_inicio + i * separacion_ranuras;
        x_pos = (ancho_total - largo_ranura) / 2;
        
        translate([x_pos, y_pos - ancho_ranura / 2, altura_total - profundidad_ranura + 0.01])
            cube([largo_ranura, ancho_ranura, profundidad_ranura + 1]);
    }
}

module texto_relieve() {
    // Ubicado en la cara frontal sobresaliendo 1 mm
    translate([ancho_total / 2, 0, (altura_total - radio_superior) / 2])
        rotate([90, 0, 0])
            linear_extrude(height = relieve_texto)
                text(texto_logo, size = tamano_fuente, font = "Arial:style=Bold", halign = "center", valign = "center");
}

// --- Ensamble Final ---
union() {
    difference() {
        cuerpo_base();
        ranuras();
    }
    texto_relieve();
}