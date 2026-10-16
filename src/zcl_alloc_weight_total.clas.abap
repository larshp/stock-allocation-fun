CLASS zcl_alloc_weight_total DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_part,
             weight   TYPE menge_d,
             quantity TYPE i,
           END OF ty_part.
    TYPES ty_part_tt TYPE STANDARD TABLE OF ty_part WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_parts        TYPE ty_part_tt
      RETURNING
        VALUE(rv_total) TYPE menge_d.

    METHODS gross
      IMPORTING
        iv_net          TYPE menge_d
        iv_tare         TYPE menge_d
        iv_parts        TYPE i
      RETURNING
        VALUE(rv_gross) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_weight_total IMPLEMENTATION.

  METHOD total.
    LOOP AT it_parts INTO DATA(ls_part).
      IF ls_part-quantity <= 0.
        CONTINUE.
      ENDIF.

      rv_total = rv_total + ls_part-weight * ls_part-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD gross.
    IF iv_parts <= 0.
      rv_gross = iv_net.
      RETURN.
    ENDIF.

    " Tare is the packaging of one part, so the gross weight adds it once per part.
    rv_gross = iv_net + iv_tare * iv_parts.
  ENDMETHOD.

ENDCLASS.
