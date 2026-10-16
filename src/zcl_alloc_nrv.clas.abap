CLASS zcl_alloc_nrv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS nrv
      IMPORTING
        iv_selling_price TYPE i
        iv_selling_cost  TYPE i
      RETURNING
        VALUE(rv_nrv)    TYPE i.

    METHODS is_impaired
      IMPORTING
        iv_cost      TYPE i
        iv_nrv       TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS write_down
      IMPORTING
        iv_cost          TYPE i
        iv_nrv           TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

ENDCLASS.


CLASS zcl_alloc_nrv IMPLEMENTATION.

  METHOD nrv.
    " The net realisable value is what selling would leave behind.
    rv_nrv = iv_selling_price - iv_selling_cost.
  ENDMETHOD.

  METHOD is_impaired.
    " Stock is impaired once its net realisable value falls below cost.
    rv_ok = xsdbool( iv_nrv < iv_cost ).
  ENDMETHOD.

  METHOD write_down.
    " The write-down is the part of cost the net realisable value falls short of.
    IF iv_nrv >= iv_cost.
      RETURN.
    ENDIF.

    rv_amount = iv_cost - iv_nrv.
  ENDMETHOD.

ENDCLASS.
