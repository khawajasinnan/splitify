-- Add currency support to groups table

ALTER TABLE groups 
ADD COLUMN IF NOT EXISTS currency TEXT DEFAULT 'PKR';

-- Update existing groups to have PKR as default currency
UPDATE groups 
SET currency = 'PKR' 
WHERE currency IS NULL;

-- Add comment for documentation
COMMENT ON COLUMN groups.currency IS 'Currency code for the group (PKR, USD, EUR, GBP, INR, AED, SAR)';
