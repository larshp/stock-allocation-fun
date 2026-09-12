CLASS ltcl_alloc_req_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_req_split.

    METHODS setup.

    METHODS requirement
      IMPORTING
        iv_qty        TYPE menge_d
      RETURNING
        VALUE(rs_row) TYPE zif_requirement_reader=>ty_requirement.

    METHODS exact_multiple FOR TESTING.
    METHODS with_remainder FOR TESTING.
    METHODS below_max      FOR TESTING.
    METHODS zero_max       FOR TESTING.
    METHODS zero_qty       FOR TESTING.
    METHODS keeps_fields   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_req_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_req_split( ).
  ENDMETHOD.

  METHOD requirement.
    rs_row-id = 'REQ-1'.
    rs_row-requested_qty = iv_qty.
    rs_row-priority = 2.
  ENDMETHOD.

  METHOD exact_multiple.
    DATA(lt_parts) = mo_cut->split( is_requirement = requirement( '20' )
                                    iv_max_qty     = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ]-requested_qty
                                        exp = '10' ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 2 ]-requested_qty
                                        exp = '10' ).
  ENDMETHOD.

  METHOD with_remainder.
    DATA(lt_parts) = mo_cut->split( is_requirement = requirement( '25' )
                                    iv_max_qty     = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 3 ]-requested_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD below_max.
    DATA(lt_parts) = mo_cut->split( is_requirement = requirement( '5' )
                                    iv_max_qty     = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ]-requested_qty
                                        exp = '5' ).
  ENDMETHOD.

  METHOD zero_max.
    DATA(lt_parts) = mo_cut->split( is_requirement = requirement( '25' )
                                    iv_max_qty     = '0' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ]-requested_qty
                                        exp = '25' ).
  ENDMETHOD.

  METHOD zero_qty.
    DATA(lt_parts) = mo_cut->split( is_requirement = requirement( '0' )
                                    iv_max_qty     = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ]-requested_qty
                                        exp = '0' ).
  ENDMETHOD.

  METHOD keeps_fields.
    DATA(lt_parts) = mo_cut->split( is_requirement = requirement( '15' )
                                    iv_max_qty     = '10' ).

    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ]-id exp = 'REQ-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ]-priority exp = 2 ).
  ENDMETHOD.

ENDCLASS.
