CLASS zcl_uom_converter DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_uom_converter.

ENDCLASS.


CLASS zcl_uom_converter IMPLEMENTATION.

  METHOD zif_uom_converter~to_base_qty.
    IF iv_meinh IS INITIAL.
      rv_base_qty = iv_qty.
      RETURN.
    ENDIF.

    SELECT SINGLE * FROM marm INTO @DATA(ls_marm)
      WHERE matnr = @iv_matnr
        AND meinh = @iv_meinh.

    IF sy-subrc <> 0 OR ls_marm-umren IS INITIAL.
      rv_base_qty = iv_qty.
      RETURN.
    ENDIF.

    rv_base_qty = iv_qty * ls_marm-umrez / ls_marm-umren.
  ENDMETHOD.

ENDCLASS.
