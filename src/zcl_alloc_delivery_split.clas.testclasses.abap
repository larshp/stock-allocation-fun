CLASS ltcl_alloc_delivery_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_delivery_split.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_quantity   TYPE menge_d
        iv_max        TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_delivery_split=>ty_input.

    METHODS exact_multiple FOR TESTING.
    METHODS with_remainder FOR TESTING.
    METHODS below_max      FOR TESTING.
    METHODS zero_max       FOR TESTING.
    METHODS zero_quantity  FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_delivery_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_delivery_split( ).
  ENDMETHOD.

  METHOD input.
    rs_row-quantity = iv_quantity.
    rs_row-max_delivery = iv_max.
  ENDMETHOD.

  METHOD exact_multiple.
    DATA(lt_parts) = mo_cut->split( input( iv_quantity = '20'
                                           iv_max      = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 2 ] exp = '10' ).
  ENDMETHOD.

  METHOD with_remainder.
    DATA(lt_parts) = mo_cut->split( input( iv_quantity = '25'
                                           iv_max      = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 3 ] exp = '5' ).
  ENDMETHOD.

  METHOD below_max.
    DATA(lt_parts) = mo_cut->split( input( iv_quantity = '5'
                                           iv_max      = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = '5' ).
  ENDMETHOD.

  METHOD zero_max.
    DATA(lt_parts) = mo_cut->split( input( iv_quantity = '25'
                                           iv_max      = '0' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = '25' ).
  ENDMETHOD.

  METHOD zero_quantity.
    DATA(lt_parts) = mo_cut->split( input( iv_quantity = '0'
                                           iv_max      = '10' ) ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = '0' ).
  ENDMETHOD.

ENDCLASS.
