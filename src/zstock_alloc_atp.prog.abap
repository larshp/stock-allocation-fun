REPORT zstock_alloc_atp.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_menge TYPE zif_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_date TYPE d.

START-OF-SELECTION.

  " which locations may be given away and whether the plan counts are
  " decisions about the plant, so the answer uses the plant's own settings
  " rather than asking again here. Nothing on this screen changes anything.
  DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
  DATA(ls_settings) = lo_config->for_plant( p_werks ).

  TRY.
      DATA(ls_promise) = zcl_atp_query=>create_default(
        iv_lgort   = ls_settings-lgort
        iv_planned = ls_settings-planned )->promise(
          iv_matnr    = p_matnr
          iv_werks    = p_werks
          iv_quantity = p_menge
          iv_by_date  = p_date ).
    CATCH zcx_allocation INTO DATA(lx_error).
      WRITE / lx_error->get_text( ).
      RETURN.
  ENDTRY.

  WRITE: / 'Asked for', p_menge.
  WRITE: / 'Can promise', ls_promise-quantity.

  IF ls_promise-quantity <= 0.
    WRITE / 'Nothing can be promised'.
    RETURN.
  ENDIF.

  IF ls_promise-date IS INITIAL.
    WRITE / 'Available now'.
  ELSE.
    WRITE: / 'Available on', ls_promise-date.
  ENDIF.

  IF ls_promise-complete = abap_false.
    WRITE / 'Short of what was asked for'.
  ENDIF.
