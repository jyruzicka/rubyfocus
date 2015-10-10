require "zip"
require "fileutils"

folders_to_stage = Dir["spec/files/ofocus_staging/*"]

folders_to_stage.each do |fol|
	new_folder_location = File.join(__dir__, "spec/files", File.basename(fol) + ".ofocus")
	if File.exists?(new_folder_location)
		if File.directory?(new_folder_location)
			# Remove it
			FileUtils::rm_rf new_folder_location
		else
			fail "File #{new_folder_location} exists and is not a directory."
		end
	end
	
	FileUtils::mkdir_p new_folder_location
	# Zip each contained file
	xml_files = Dir[File.join(fol, "*.xml")]
	xml_files.each do |xml_file|
		zipfile = File.join(new_folder_location, File.basename(xml_file).gsub(".xml", ".zip"))
		Zip::File.open(zipfile, Zip::File::CREATE) do |zf|
			zf.add("contents.xml", xml_file)
		end
	end
end