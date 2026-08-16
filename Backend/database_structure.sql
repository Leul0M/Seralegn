-- Profiles (extends auth.users)
profiles (
  id uuid PRIMARY KEY REFERENCES auth.users,
  name text NOT NULL,
  phone text UNIQUE NOT NULL,
  role text CHECK (role IN ('homeowner','worker','admin')),
  verification_status text DEFAULT 'unverified',
  skills text[],
  rating numeric(3,2) DEFAULT 5.0,
  review_count int DEFAULT 0,
  flags int DEFAULT 0,
  is_banned boolean DEFAULT false,
  ban_expiry timestamptz,
  joined_at timestamptz DEFAULT now()
)

-- Jobs
jobs (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  homeowner_id uuid REFERENCES profiles,
  title text NOT NULL,
  category text NOT NULL,
  description text,
  photos text[],              -- Supabase Storage URLs
  offered_price numeric NOT NULL,
  suggested_price_min numeric,
  suggested_price_max numeric,
  status text DEFAULT 'open',
  -- open | counter_offered | work_pending | in_progress | completed | cancelled | disputed
  accepted_worker_id uuid REFERENCES profiles,
  counter_offer_price numeric,
  counter_offer_worker_id uuid REFERENCES profiles,
  counter_offer_message text,
  location text,
  area text,                  -- Addis sub-city / neighborhood
  created_at timestamptz DEFAULT now(),
  started_at timestamptz,
  completed_at timestamptz
)

-- Payments (Chapa transactions)
payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id uuid REFERENCES jobs,
  payer_id uuid REFERENCES profiles,
  amount numeric NOT NULL,
  platform_fee numeric,       -- 10% of job value
  type text CHECK (type IN ('deposit_20', 'final_80')),
  status text CHECK (status IN ('pending','success','failed')),
  chapa_tx_ref text UNIQUE,
  chapa_response jsonb,
  created_at timestamptz DEFAULT now()
)

-- Disputes
disputes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id uuid REFERENCES jobs,
  raised_by uuid REFERENCES profiles,
  against uuid REFERENCES profiles,
  reason text NOT NULL,
  status text DEFAULT 'open',
  resolution text,
  resolved_by uuid REFERENCES profiles,
  created_at timestamptz DEFAULT now(),
  resolved_at timestamptz
)

-- Flags
flags (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles,
  reason text NOT NULL,
  job_id uuid REFERENCES jobs,
  issued_by uuid REFERENCES profiles,
  created_at timestamptz DEFAULT now()
)

-- Verifications
verifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES profiles UNIQUE,
  id_document_url text,       -- Supabase Storage
  selfie_url text,
  status text DEFAULT 'pending',
  reviewed_by uuid REFERENCES profiles,
  rejection_reason text,
  submitted_at timestamptz DEFAULT now(),
  reviewed_at timestamptz
)

-- Reviews
reviews (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  job_id uuid REFERENCES jobs,
  reviewer_id uuid REFERENCES profiles,
  reviewee_id uuid REFERENCES profiles,
  rating int CHECK (rating BETWEEN 1 AND 5),
  comment text,
  created_at timestamptz DEFAULT now()
)
