CLASS ltcl_alloc_ship_csv DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_ship_csv.

    METHODS setup.

    METHODS header_only FOR TESTING.
    METHODS one_line    FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_ship_csv IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_ship_csv( ).
  ENDMETHOD.

  METHOD header_only.
    DATA lt_ships TYPE zcl_alloc_shipment=>ty_line_tt.

    DATA(lt_lines) = mo_cut->build( lt_ships ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_lines ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_lines[ 1 ]
      exp = 'SHIPMENT;LGORT;POSITIONS;QUANTITY' ).
  ENDMETHOD.

  METHOD one_line.
    DATA lt_ships TYPE zcl_alloc_shipment=>ty_line_tt.
    DATA ls_ship  TYPE zcl_alloc_shipment=>ty_line.

    ls_ship-shipment = 1.
    ls_ship-lgort = '0001'.
    ls_ship-positions = 2.
    ls_ship-quantity = '7'.
    APPEND ls_ship TO lt_ships.

    DATA(lt_lines) = mo_cut->build( lt_ships ).

    cl_abap_unit_assert=>assert_equals( act = lt_lines[ 2 ]
                                        exp = '1;0001;2;7.000' ).
  ENDMETHOD.

ENDCLASS.
