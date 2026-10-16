CLASS zcl_alloc_pack_pattern DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS cartons
      IMPORTING
        iv_quantity       TYPE i
        iv_per_carton     TYPE i
      RETURNING
        VALUE(rv_cartons) TYPE i.

    METHODS full_cartons
      IMPORTING
        iv_quantity            TYPE i
        iv_per_carton          TYPE i
      RETURNING
        VALUE(rv_full_cartons) TYPE i.

    METHODS remainder
      IMPORTING
        iv_quantity         TYPE i
        iv_per_carton       TYPE i
      RETURNING
        VALUE(rv_remainder) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pack_pattern IMPLEMENTATION.

  METHOD cartons.
    IF iv_quantity <= 0 OR iv_per_carton <= 0.
      RETURN.
    ENDIF.

    " Round up without floating point: ( q + p - 1 ) / p counts a partial carton
    " as a whole carton.
    rv_cartons = ( iv_quantity + iv_per_carton - 1 ) DIV iv_per_carton.
  ENDMETHOD.

  METHOD full_cartons.
    IF iv_quantity <= 0 OR iv_per_carton <= 0.
      RETURN.
    ENDIF.

    rv_full_cartons = iv_quantity DIV iv_per_carton.
  ENDMETHOD.

  METHOD remainder.
    IF iv_quantity <= 0 OR iv_per_carton <= 0.
      RETURN.
    ENDIF.

    rv_remainder = iv_quantity - ( iv_quantity DIV iv_per_carton )
                   * iv_per_carton.
  ENDMETHOD.

ENDCLASS.
