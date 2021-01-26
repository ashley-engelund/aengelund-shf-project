class AdminController < AdminOnlyController

  # FIXME - this is really an exporter!

  def export_ansokan_csv
    export_csv(AdminOnly::Reports::ShfApplicationsCsvReport.new)
  end


  def export_payments_csv
    export_csv(AdminOnly::Reports::PaymentsCsvReport.new)
  end


  def export_payments_covering_year_csv
    export_csv(AdminOnly::Reports::PaymentsCoveringYearCsvReport.new(params[:year]))
  end


  private

  def export_csv(csv_report)
    export_file(csv_report.to_csv, csv_report.csv_filename, success_msg: t('.success'), error_msg: t('.error'))
  end


  def export_file(file_contents_str, export_filename,
                  success_msg: 'Success!', error_msg: 'Error: something went wrong with the export.')
    begin
      send_data(file_contents_str,
                filename: export_filename, type: "text/plain")

      helpers.flash_message(:notice, success_msg)

    rescue => e
      helpers.flash_message(:alert, error_msg)
      redirect_to(request.referer.present? ? :back : root_path)
    end

  end
end
