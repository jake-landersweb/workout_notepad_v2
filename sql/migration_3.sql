CREATE TABLE IF NOT EXISTS custom_log_builder (
    id TEXT PRIMARY KEY,

    title TEXT NOT NULL,
    grouping TEXT NOT NULL,
    column TEXT NOT NULL,
    condensing TEXT NOT NULL,
    weightNormalization TEXT NOT NULL,
    graphType TEXT NOT NULL,
    sortIndex INT NOT NULL DEFAULT 0,
    data JSONB NOT NULL,
    metadata JSONB NOT NULL DEFAULT '{}',

    created DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);