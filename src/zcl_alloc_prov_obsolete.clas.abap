CLASS zcl_alloc_prov_obsolete DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS provision
      IMPORTING
        iv_value         TYPE i
        iv_percent       TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS percent
      IMPORTING
        iv_value          TYPE i
        iv_provision      TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS is_provisioned
      IMPORTING
        iv_percent   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prov_obsolete IMPLEMENTATION.

  METHOD provision.
    " The obsolescence provision is a share of the stock value.
    rv_amount = iv_value * iv_percent DIV 100.
  ENDMETHOD.

  METHOD percent.
    " The provision rate is the provision related to the stock value.
    IF iv_value <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_provision * 100 DIV iv_value.
  ENDMETHOD.

  METHOD is_provisioned.
    " Stock is provisioned once a rate is set for it.
    rv_ok = xsdbool( iv_percent > 0 ).
  ENDMETHOD.

ENDCLASS.
