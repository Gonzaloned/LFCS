// =============================================================
// GoCode - Base para 3 tarjetas de reseñas (v2 MVP)
// Unidades: mm. Diseñada para tarjetas de acrílico 70 x 120 x 2.4 mm.
// Sin librerías externas.
//
// Impresión recomendada: base apoyada sobre su cara inferior (Z=0).
// La línea perimetral queda como canal para pintar/destacar en dorado.
// El lastre se agrega DESPUÉS, pegando una placa metálica bajo la base.
// =============================================================

// ---------- SALIDA ----------
pieza = "base"; // [base]

// ---------- BASE ----------
ancho_total       = 80;  // X
profundidad_total = 60;  // Y
altura_total      = 30;  // Z
radio_esquinas    = 5;   // esquinas verticales
radio_superior    = 1.5; // redondeo suave del borde superior
segmentos_borde   = 12;  // suavidad de la curva superior

// ---------- TARJETAS Y RANURAS ----------
ancho_tarjeta      = 70;  // tarjeta: 70 mm de ancho x 120 mm de alto
espesor_tarjeta    = 2.4; // acrílico nominal
holgura_total      = 0.4; // holgura total inicial para impresión FDM
largo_ranura       = ancho_tarjeta + 2.0; // 1 mm libre a cada extremo
ancho_ranura       = espesor_tarjeta + holgura_total; // 2.8 mm
cantidad_ranuras   = 3;
separacion_ranuras = 15;  // distancia entre centros de ranuras
profundidad_ranura = 18;  // inserción de la tarjeta

// ---------- CANAL DECORATIVO INFERIOR ----------
canal_z      = 3.0; // altura desde la cara inferior
canal_alto   = 0.8; // altura del canal
canal_fondo  = 0.6; // profundidad del canal en el lateral

// ---------- LOGO FRONTAL ----------
mostrar_logo  = true;
texto_logo    = "GoCode";
tamano_fuente = 11;
relieve_logo  = 0.6;
fuente_logo   = "DejaVu Sans:style=Bold";

// ---------- CALIDAD ----------
$fn = 64;
eps = 0.03;

// ---------- RECTÁNGULO 2D CON ESQUINAS REDONDEADAS ----------
module rectangulo_redondeado_2d(ancho, fondo, radio) {
    offset(r = radio)
        square([ancho - 2*radio, fondo - 2*radio], center = true);
}

module perfil_exterior_2d() {
    rectangulo_redondeado_2d(ancho_total, profundidad_total, radio_esquinas);
}

// ---------- REDONDEO DEL BORDE SUPERIOR ----------
// Aproxima un cuarto de círculo con secciones pequeñas. Las paredes
// verticales conservan las dimensiones nominales de la base.
function inset_borde(t) = radio_superior -
    sqrt(max(0, radio_superior*radio_superior - t*t));

module seccion_borde(t) {
    translate([0, 0, altura_total - radio_superior + t - eps])
        linear_extrude(height = eps)
            offset(delta = -inset_borde(t))
                perfil_exterior_2d();
}

module borde_superior_redondeado() {
    for (i = [0 : segmentos_borde - 1]) {
        t1 = radio_superior * i / segmentos_borde;
        t2 = radio_superior * (i + 1) / segmentos_borde;
        hull() {
            seccion_borde(t1);
            seccion_borde(t2);
        }
    }
}

module cuerpo_exterior() {
    union() {
        linear_extrude(height = altura_total - radio_superior)
            perfil_exterior_2d();
        borde_superior_redondeado();
    }
}

// ---------- RANURAS ----------
module cortes_ranuras() {
    for (i = [0 : cantidad_ranuras - 1]) {
        y = (i - (cantidad_ranuras - 1)/2) * separacion_ranuras;
        translate([-largo_ranura/2,
                   y - ancho_ranura/2,
                   altura_total - profundidad_ranura])
            cube([largo_ranura, ancho_ranura, profundidad_ranura + 1]);
    }
}

// ---------- CANAL HUNDIDO EN TODO EL PERÍMETRO ----------
module corte_canal_perimetral() {
    translate([0, 0, canal_z])
        linear_extrude(height = canal_alto)
            difference() {
                perfil_exterior_2d();
                offset(delta = -canal_fondo)
                    perfil_exterior_2d();
            }
}

// ---------- LOGO EN RELIEVE SOBRE EL FRENTE ----------
module logo_frontal() {
    if (mostrar_logo) {
        // El frente es el lateral Y negativo. El relieve sobresale hacia afuera.
        translate([0, -profundidad_total/2 + 0.02, altura_total/2])
            rotate([90, 0, 0])
                linear_extrude(height = relieve_logo)
                    text(texto_logo,
                         size = tamano_fuente,
                         font = fuente_logo,
                         halign = "center",
                         valign = "center");
    }
}

// ---------- LASTRE: ALOJAMIENTOS INFERIORES ----------
usar_alojamientos_peso = true;

diametro_alojamiento_peso = 18.2;
profundidad_alojamiento_peso = 7.2;

posicion_peso_x = 22;
posicion_peso_y = 14;

// ---------- ALOJAMIENTOS DE LASTRE ----------
module cortes_alojamientos_peso() {

    if (usar_alojamientos_peso) {

        for (x = [-posicion_peso_x, posicion_peso_x]) {
            for (y = [-posicion_peso_y, posicion_peso_y]) {

                translate([x, y, -eps])
                    cylinder(
                        d = diametro_alojamiento_peso,
                        h = profundidad_alojamiento_peso + eps
                    );
            }
        }
    }
}

// ---------- MODELO FINAL ----------
module base_gocode() {
    difference() {
        union() {
            cuerpo_exterior();
            logo_frontal();
        }
        cortes_ranuras();
        cortes_alojamientos_peso();
        corte_canal_perimetral();
    }
}

if (pieza == "base") {
    base_gocode();
}
