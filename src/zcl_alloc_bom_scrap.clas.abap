CLASS zcl_alloc_bom_scrap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS scrap_qty
      IMPORTING
        iv_gross         TYPE i
        iv_scrap_percent TYPE i
      RETURNING
        VALUE(rv_scrap)  TYPE i.

    METHODS is_scrapped
      IMPORTING
        iv_scrap     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS gross_qty
      IMPORTING
        iv_net           TYPE i
        iv_scrap_percent TYPE i
      RETURNING
        VALUE(rv_gross)  TYPE i.

ENDCLASS.


CLASS zcl_alloc_bom_scrap IMPLEMENTATION.

  METHOD scrap_qty.
    " The scrap is the gross quantity at the scrap percentage.
    IF iv_gross <= 0 OR iv_scrap_percent <= 0.
      RETURN.
    ENDIF.

    rv_scrap = iv_gross * iv_scrap_percent DIV 100.
  ENDMETHOD.

  METHOD is_scrapped.
    " The component is scrapped once any part of it is lost.
    rv_ok = xsdbool( iv_scrap > 0 ).
  ENDMETHOD.

  METHOD gross_qty.
    DATA lv_net_share TYPE i.

    " The gross quantity needed to leave the net after scrap.
    IF iv_scrap_percent <= 0 OR iv_scrap_percent >= 100.
      rv_gross = iv_net.
      RETURN.
    ENDIF.

    lv_net_share = 100 - iv_scrap_percent.
    rv_gross = iv_net * 100 DIV lv_net_share.
  ENDMETHOD.

ENDCLASS.
