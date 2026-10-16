CLASS ltcl_alloc_mrp DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_mrp.
    DATA mt_dem TYPE zcl_alloc_mrp=>ty_requirement_tt.
    DATA mt_bom TYPE zcl_alloc_mrp=>ty_bom_tt.

    METHODS setup.

    METHODS add_demand
      IMPORTING
        iv_matnr TYPE matnr
        iv_qty   TYPE menge_d.

    METHODS add_bom
      IMPORTING
        iv_parent TYPE matnr
        iv_child  TYPE matnr
        iv_qty    TYPE menge_d.

    METHODS empty_demand       FOR TESTING.
    METHODS level_zero         FOR TESTING.
    METHODS one_level_explosion FOR TESTING.
    METHODS two_level_explosion FOR TESTING.
    METHODS aggregates_children FOR TESTING.
    METHODS skips_zero_demand   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_mrp IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_mrp( ).
  ENDMETHOD.

  METHOD add_demand.
    DATA ls_requirement TYPE zcl_alloc_mrp=>ty_requirement.

    ls_requirement-matnr = iv_matnr.
    ls_requirement-quantity = iv_qty.
    APPEND ls_requirement TO mt_dem.
  ENDMETHOD.

  METHOD add_bom.
    DATA ls_bom TYPE zcl_alloc_mrp=>ty_bom.

    ls_bom-parent_matnr = iv_parent.
    ls_bom-child_matnr = iv_child.
    ls_bom-qty_per = iv_qty.
    APPEND ls_bom TO mt_bom.
  ENDMETHOD.

  METHOD empty_demand.
    DATA(lt_planned) = mo_cut->run( it_demand = mt_dem
                                    it_bom    = mt_bom
                                    iv_levels = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_planned ) exp = 0 ).
  ENDMETHOD.

  METHOD level_zero.
    add_demand( iv_matnr = 'M1' iv_qty = 10 ).
    add_bom( iv_parent = 'M1' iv_child = 'C1' iv_qty = 2 ).

    DATA(lt_planned) = mo_cut->run( it_demand = mt_dem
                                    it_bom    = mt_bom
                                    iv_levels = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_planned ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 1 ]-quantity exp = 10 ).
  ENDMETHOD.

  METHOD one_level_explosion.
    add_demand( iv_matnr = 'M1' iv_qty = 10 ).
    add_bom( iv_parent = 'M1' iv_child = 'C1' iv_qty = 2 ).
    add_bom( iv_parent = 'M1' iv_child = 'C2' iv_qty = 1 ).

    DATA(lt_planned) = mo_cut->run( it_demand = mt_dem
                                    it_bom    = mt_bom
                                    iv_levels = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_planned ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 1 ]-quantity exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 2 ]-quantity exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 3 ]-quantity exp = 10 ).
  ENDMETHOD.

  METHOD two_level_explosion.
    add_demand( iv_matnr = 'M1' iv_qty = 10 ).
    add_bom( iv_parent = 'M1' iv_child = 'C1' iv_qty = 2 ).
    add_bom( iv_parent = 'C1' iv_child = 'D1' iv_qty = 3 ).

    DATA(lt_planned) = mo_cut->run( it_demand = mt_dem
                                    it_bom    = mt_bom
                                    iv_levels = 2 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_planned ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 1 ]-quantity exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 2 ]-quantity exp = 20 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 3 ]-quantity exp = 60 ).
  ENDMETHOD.

  METHOD aggregates_children.
    add_demand( iv_matnr = 'M1' iv_qty = 10 ).
    add_demand( iv_matnr = 'M2' iv_qty = 5 ).
    add_bom( iv_parent = 'M1' iv_child = 'C1' iv_qty = 1 ).
    add_bom( iv_parent = 'M2' iv_child = 'C1' iv_qty = 1 ).

    DATA(lt_planned) = mo_cut->run( it_demand = mt_dem
                                    it_bom    = mt_bom
                                    iv_levels = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_planned ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_planned[ 3 ]-quantity exp = 15 ).
  ENDMETHOD.

  METHOD skips_zero_demand.
    add_demand( iv_matnr = 'M1' iv_qty = 0 ).
    add_bom( iv_parent = 'M1' iv_child = 'C1' iv_qty = 2 ).

    DATA(lt_planned) = mo_cut->run( it_demand = mt_dem
                                    it_bom    = mt_bom
                                    iv_levels = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_planned ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
