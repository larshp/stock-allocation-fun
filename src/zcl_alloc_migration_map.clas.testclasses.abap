CLASS ltcl_alloc_migration_map DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut     TYPE REF TO zcl_alloc_migration_map.
    DATA mt_mapping TYPE zcl_alloc_migration_map=>ty_mapping_tt.
    DATA mt_record  TYPE zcl_alloc_migration_map=>ty_record_tt.

    METHODS setup.

    METHODS add_mapping
      IMPORTING
        iv_old TYPE string
        iv_new TYPE string.

    METHODS add_record
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE string.

    METHODS renames_field     FOR TESTING.
    METHODS keeps_unknown     FOR TESTING.
    METHODS keeps_value       FOR TESTING.
    METHODS empty_mapping     FOR TESTING.
    METHODS empty_record      FOR TESTING.
    METHODS mapped_flag       FOR TESTING.
    METHODS multiple_records  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_migration_map IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_migration_map( ).

    add_mapping( iv_old = 'MATNR' iv_new = 'MATERIAL' ).
    add_mapping( iv_old = 'WERKS' iv_new = 'PLANT' ).
  ENDMETHOD.

  METHOD add_mapping.
    DATA ls_mapping TYPE zcl_alloc_migration_map=>ty_mapping.

    ls_mapping-old_field = iv_old.
    ls_mapping-new_field = iv_new.
    APPEND ls_mapping TO mt_mapping.
  ENDMETHOD.

  METHOD add_record.
    DATA ls_record TYPE zcl_alloc_migration_map=>ty_record.

    ls_record-field_name = iv_name.
    ls_record-field_value = iv_value.
    APPEND ls_record TO mt_record.
  ENDMETHOD.

  METHOD renames_field.
    add_record( iv_name = 'MATNR' iv_value = 'M-1' ).

    DATA(lt_mapped) = mo_cut->map( it_mapping = mt_mapping
                                   it_record  = mt_record ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_mapped ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 1 ]-field_name exp = 'MATERIAL' ).
  ENDMETHOD.

  METHOD keeps_unknown.
    add_record( iv_name = 'ZZFIELD' iv_value = 'x' ).

    DATA(lt_mapped) = mo_cut->map( it_mapping = mt_mapping
                                   it_record  = mt_record ).

    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 1 ]-field_name exp = 'ZZFIELD' ).
  ENDMETHOD.

  METHOD keeps_value.
    add_record( iv_name = 'WERKS' iv_value = '1000' ).

    DATA(lt_mapped) = mo_cut->map( it_mapping = mt_mapping
                                   it_record  = mt_record ).

    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 1 ]-field_name exp = 'PLANT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 1 ]-field_value exp = '1000' ).
  ENDMETHOD.

  METHOD empty_mapping.
    DATA lt_empty TYPE zcl_alloc_migration_map=>ty_mapping_tt.

    add_record( iv_name = 'MATNR' iv_value = 'M-1' ).

    DATA(lt_mapped) = mo_cut->map( it_mapping = lt_empty
                                   it_record  = mt_record ).

    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 1 ]-field_name exp = 'MATNR' ).
  ENDMETHOD.

  METHOD empty_record.
    DATA(lt_mapped) = mo_cut->map( it_mapping = mt_mapping
                                   it_record  = mt_record ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_mapped ) exp = 0 ).
  ENDMETHOD.

  METHOD mapped_flag.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_mapped( it_mapping = mt_mapping iv_field = 'MATNR' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_mapped( it_mapping = mt_mapping iv_field = 'NOPE' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD multiple_records.
    add_record( iv_name = 'MATNR' iv_value = 'M-1' ).
    add_record( iv_name = 'WERKS' iv_value = '1000' ).
    add_record( iv_name = 'EXTRA' iv_value = 'z' ).

    DATA(lt_mapped) = mo_cut->map( it_mapping = mt_mapping
                                   it_record  = mt_record ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_mapped ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 1 ]-field_name exp = 'MATERIAL' ).
    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 2 ]-field_name exp = 'PLANT' ).
    cl_abap_unit_assert=>assert_equals( act = lt_mapped[ 3 ]-field_name exp = 'EXTRA' ).
  ENDMETHOD.

ENDCLASS.
