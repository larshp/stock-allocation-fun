CLASS ltcl_alloc_toc DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_toc.
    DATA mt_sec TYPE zcl_alloc_toc=>ty_section_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_title TYPE string
        iv_level TYPE i.

    METHODS empty_sections FOR TESTING.
    METHODS flat_numbering FOR TESTING.
    METHODS nested_numbering FOR TESTING.
    METHODS resets_children  FOR TESTING.
    METHODS indents_by_level FOR TESTING.
    METHODS clamps_level     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_toc IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_toc( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_section TYPE zcl_alloc_toc=>ty_section.

    ls_section-title = iv_title.
    ls_section-level = iv_level.
    APPEND ls_section TO mt_sec.
  ENDMETHOD.

  METHOD empty_sections.
    DATA(lt_entries) = mo_cut->build( mt_sec ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 0 ).
  ENDMETHOD.

  METHOD flat_numbering.
    add( iv_title = 'First' iv_level = 1 ).
    add( iv_title = 'Second' iv_level = 1 ).

    DATA(lt_entries) = mo_cut->build( mt_sec ).

    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-number exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 2 ]-number exp = '2' ).
  ENDMETHOD.

  METHOD nested_numbering.
    add( iv_title = 'One' iv_level = 1 ).
    add( iv_title = 'One.One' iv_level = 2 ).
    add( iv_title = 'One.Two' iv_level = 2 ).

    DATA(lt_entries) = mo_cut->build( mt_sec ).

    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-number exp = '1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 2 ]-number exp = '1.1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 3 ]-number exp = '1.2' ).
  ENDMETHOD.

  METHOD resets_children.
    add( iv_title = 'One' iv_level = 1 ).
    add( iv_title = 'One.One' iv_level = 2 ).
    add( iv_title = 'Two' iv_level = 1 ).
    add( iv_title = 'Two.One' iv_level = 2 ).

    DATA(lt_entries) = mo_cut->build( mt_sec ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_entries ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 3 ]-number exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 4 ]-number exp = '2.1' ).
  ENDMETHOD.

  METHOD indents_by_level.
    add( iv_title = 'One' iv_level = 1 ).
    add( iv_title = 'One.One' iv_level = 2 ).
    add( iv_title = 'Deep' iv_level = 3 ).

    DATA(lt_entries) = mo_cut->build( mt_sec ).

    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-indent exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 2 ]-indent exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 3 ]-indent exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 3 ]-number exp = '1.1.1' ).
  ENDMETHOD.

  METHOD clamps_level.
    add( iv_title = 'Zero' iv_level = 0 ).
    add( iv_title = 'Deep' iv_level = 9 ).

    DATA(lt_entries) = mo_cut->build( mt_sec ).

    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 1 ]-level exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_entries[ 2 ]-level exp = 3 ).
  ENDMETHOD.

ENDCLASS.
