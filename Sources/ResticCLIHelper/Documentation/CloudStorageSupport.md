# Cloud Storage Support for Restic CLI Helper

This document outlines the planned support for various cloud storage backends in the Restic CLI Helper.

## Currently Supported
- Local filesystem repositories

## Planned Support

### Amazon S3
- Standard S3 buckets
- S3-compatible services (Minio, Wasabi, etc.)
- Required environment variables:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`
  - `AWS_DEFAULT_REGION`
- Repository format: `s3:s3.amazonaws.com/bucket_name/path`

### Microsoft Azure
- Azure Blob Storage
- Required environment variables:
  - `AZURE_ACCOUNT_NAME`
  - `AZURE_ACCOUNT_KEY`
- Repository format: `azure:container-name:/path`

### Google Cloud Storage
- GCS buckets
- Required environment variables:
  - `GOOGLE_PROJECT_ID`
  - `GOOGLE_APPLICATION_CREDENTIALS`
- Repository format: `gs:bucket-name:/path`

## Implementation Plan

1. Phase 1: Local Repository Support (Current)
   - Basic repository operations
   - Full test coverage
   - Command builders and validation

2. Phase 2: Amazon S3 Support
   - S3 repository initialization
   - Credential management
   - Region configuration
   - Transfer optimizations

3. Phase 3: Azure Support
   - Azure Blob Storage integration
   - SAS token support
   - Connection string handling
   - Performance tuning

4. Phase 4: Google Cloud Support
   - GCS bucket management
   - Service account integration
   - IAM role support
   - Transfer optimizations

## Security Considerations

- All cloud provider credentials should be handled securely
- Support for environment variables and configuration files
- Integration with system keychains where applicable
- Support for IAM roles and managed identities
- Secure credential rotation

## Testing Strategy

Each cloud provider implementation will require:
- Integration tests with real cloud services
- Mock tests for offline development
- Performance benchmarks
- Error handling verification
- Credential management tests

## Documentation Requirements

For each cloud provider:
- Setup guides
- Authentication examples
- Performance recommendations
- Troubleshooting guides
- Cost optimization tips
