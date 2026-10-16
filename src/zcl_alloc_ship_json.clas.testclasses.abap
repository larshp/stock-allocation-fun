CLASS ltcl_alloc_ship_json DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_ship_json.

    METHODS setup.

    METHODS empty_list FOR TESTING.
    METHODS one_line   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_ship_json IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_ship_json( ).
  ENDMETHOD.

  METHOD empty_list.
    DATA lt_ships TYPE zcl_alloc_shipment=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals( act = mo_cut->build( lt_ships )
                                        exp = '[]' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_ships TYPE zcl_alloc_shipment=>ty_line_tt.
    DATA ls_ship  TYPE zcl_alloc_shipment=>ty_line.

    ls_ship-shipment = 1.
    ls_ship-lgort = '0001'.
    ls_ship-positions = 2.
    ls_ship-quantity = '7'.
    APPEND ls_ship TO lt_ships.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->build( lt_ships )
      exp = '[{"shipment":1,"lgort":"0001","positions":2,' &&
            '"quantity":7.000}]' ).
  ENDMETHOD.

ENDCLASS.
